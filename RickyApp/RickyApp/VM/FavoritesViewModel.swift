//
//  FavoritesViewModel.swift
//  RickyApp
//
//  Created by Enes on 22.10.2025.
//

import Foundation
import Combine
import RickyDI
import RickyDomain
import RickyPersistance

/// ViewModel for favorites list screen
/// Follows Clean Architecture by using repositories and domain entities
@MainActor
final class FavoritesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var favoriteCharacters: [CharacterEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchQuery: String = ""
    
    // MARK: - Dependencies
    
    private let characterRepository: CharacterRepositoryProtocol
    private let favoritesRepository: FavoritesRepository
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var hasFavorites: Bool {
        !favoriteCharacters.isEmpty
    }
    
    var displayedCharacters: [CharacterEntity] {
        if searchQuery.isEmpty {
            return favoriteCharacters
        } else {
            return favoriteCharacters.filter { character in
                character.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    // MARK: - Initialization
    
    init(
        characterRepository: CharacterRepositoryProtocol = ServiceContainer.shared.characterRepository.resolve(),
        favoritesRepository: FavoritesRepository = ServiceContainer.shared.favoritesRepository.resolve()
    ) {
        self.characterRepository = characterRepository
        self.favoritesRepository = favoritesRepository
        
        setupObservers()
        loadFavorites()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Observe favorites repository changes
        favoritesRepository.$favorites
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load favorite characters from repository
    func loadFavorites() {
        isLoading = true
        errorMessage = nil
        
        characterRepository
            .getFavoriteCharacters()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.errorDescription
                    self?.favoriteCharacters = []
                }
            } receiveValue: { [weak self] entities in
                self?.favoriteCharacters = entities
            }
            .store(in: &cancellables)
    }
    
    /// Remove character from favorites
    func removeFavorite(characterId: Int) {
        guard let character = favoriteCharacters.first(where: { $0.id == characterId }) else {
            return
        }
        
        // Optimistic update
        let oldCharacters = favoriteCharacters
        favoriteCharacters.removeAll { $0.id == characterId }
        
        characterRepository
            .toggleFavorite(characterId: characterId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    // Revert on error
                    self?.favoriteCharacters = oldCharacters
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { _ in
                // Success
            }
            .store(in: &cancellables)
    }
    
    /// Refresh favorites list
    func refresh() {
        loadFavorites()
    }
    
    /// Delete all favorites (for testing)
    func deleteAllFavorites() {
        favoritesRepository.deleteAllFavorites()
        favoriteCharacters = []
    }
}

