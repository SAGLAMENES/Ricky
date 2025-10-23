//
//  CharacterListViewModel.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import Combine
import RickyDI
import RickyDomain
import RickyAppCore
import RickyPersistance
import RickyAnalytics

/// ViewModel for character list screen
/// Follows Clean Architecture by using Use Cases from Domain layer
@MainActor
final class CharacterListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var characters: [CharacterEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentPage: Int = 1
    @Published var searchQuery: String = ""

    // MARK: - Dependencies

    private let fetchCharactersUseCase: FetchCharactersUseCase
    private let searchCharactersUseCase: SearchCharactersUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let favoritesRepository: FavoritesRepository
    private let analyticsService: AnalyticsServiceProtocol
    let networkMonitor = NetworkMonitor.shared

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var canLoadMore = true
    private var searchDebounceWorkItem: DispatchWorkItem?

    // MARK: - Initialization

    init(
        fetchCharactersUseCase: FetchCharactersUseCase = ServiceContainer.shared.fetchCharactersUseCase.resolve(),
        searchCharactersUseCase: SearchCharactersUseCase = ServiceContainer.shared.searchCharactersUseCase.resolve(),
        toggleFavoriteUseCase: ToggleFavoriteUseCase = ServiceContainer.shared.toggleFavoriteUseCase.resolve(),
        favoritesRepository: FavoritesRepository = ServiceContainer.shared.favoritesRepository.resolve(),
        analyticsService: AnalyticsServiceProtocol = ServiceContainer.shared.analyticsService.resolve()
    ) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
        self.searchCharactersUseCase = searchCharactersUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.favoritesRepository = favoritesRepository
        self.analyticsService = analyticsService

        setupSearchDebouncing()
        setupFavoritesObserver()
        
        analyticsService.logEvent(.screenView(screen: .characterList))
    }

    // MARK: - Setup

    private func setupSearchDebouncing() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func setupFavoritesObserver() {
        favoritesRepository.$favorites
            .map { favorites in
                Set(favorites.map { $0.id })
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteIds in
                self?.updateFavoriteStates(with: favoriteIds)
            }
            .store(in: &cancellables)
    }
    
    private func updateFavoriteStates(with favoriteIds: Set<Int>) {
        for index in characters.indices {
            let currentCharacter = characters[index]
            let shouldBeFavorite = favoriteIds.contains(currentCharacter.id)
            
            if currentCharacter.isFavorite != shouldBeFavorite {
                characters[index] = currentCharacter.withFavorite(shouldBeFavorite)
            }
        }
    }

    // MARK: - Public Methods

    /// Fetch characters for the current page
    func fetchCharacters(refresh: Bool = false) {
        guard !isLoading else { return }

        if refresh {
            currentPage = 1
            characters = []
            canLoadMore = true
        }

        isLoading = true
        errorMessage = nil

        let parameters = FetchCharactersParameters(page: currentPage, refresh: refresh)

        fetchCharactersUseCase
            .execute(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.errorDescription
                    self?.canLoadMore = false
                }
            } receiveValue: { [weak self] entities in
                guard let self = self else { return }

                if refresh {
                    self.characters = entities
                } else {
                    self.characters.append(contentsOf: entities)
                }

                // If we received fewer than expected, we've reached the end
                if entities.isEmpty {
                    self.canLoadMore = false
                }
            }
            .store(in: &cancellables)
    }

    /// Load next page of characters
    func loadMore() {
        guard canLoadMore, !isLoading else { return }
        currentPage += 1
        fetchCharacters()
    }

    /// Search characters by name (with debouncing)
    func searchCharacters() {
        // This method is now deprecated in favor of automatic debouncing
        // Keeping for backward compatibility
        performSearch(query: searchQuery)
    }

    /// Perform search with debouncing
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            fetchCharacters(refresh: true)
            return
        }

        // Check network connectivity
        guard networkMonitor.isConnected else {
            errorMessage = "No internet connection. Showing cached results."
            return
        }

        isLoading = true
        errorMessage = nil

        let parameters = SearchCharactersParameters(
            name: query,
            status: nil,
            species: nil,
            gender: nil,
            page: 1
        )

        searchCharactersUseCase
            .execute(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] entities in
                guard let self = self else { return }
                self.characters = entities
                self.analyticsService.logEvent(.characterSearch(query: query, resultsCount: entities.count))
            }
            .store(in: &cancellables)
    }

    /// Toggle favorite status for a character with optimistic update
    func toggleFavorite(characterId: Int) {
        // Find character index
        guard let index = characters.firstIndex(where: { $0.id == characterId }) else {
            return
        }

        // Optimistic update - immediately update UI
        let oldCharacter = characters[index]
        let newFavoriteStatus = !oldCharacter.isFavorite
        characters[index] = oldCharacter.withFavorite(newFavoriteStatus)

        // Perform backend update
        let parameters = ToggleFavoriteParameters(characterId: characterId)

        toggleFavoriteUseCase
            .execute(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    // Revert on error
                    if let idx = self?.characters.firstIndex(where: { $0.id == characterId }) {
                        self?.characters[idx] = oldCharacter
                    }
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                
                if newFavoriteStatus {
                    self.analyticsService.logEvent(.characterAddedToFavorites(
                        characterId: oldCharacter.id,
                        characterName: oldCharacter.name
                    ))
                } else {
                    self.analyticsService.logEvent(.characterRemovedFromFavorites(
                        characterId: oldCharacter.id,
                        characterName: oldCharacter.name
                    ))
                }
            }
            .store(in: &cancellables)
    }

    /// Refresh the character list
    func refresh() {
        fetchCharacters(refresh: true)
    }

    // MARK: - Computed Properties

    var hasCharacters: Bool {
        !characters.isEmpty
    }

    var displayedCharacters: [CharacterEntity] {
        characters
    }
}
