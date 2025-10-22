//
//  CharacterRepository.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine
import RickyDomain
import RickyNetworkInterface
import RickyNetwork
import RickyPersistance
import RickyModel
import RickyConfiguration

/// Implementation of CharacterRepositoryProtocol
/// Handles character data fetching with caching strategy
public final class CharacterRepository: CharacterRepositoryProtocol {

    // MARK: - Dependencies

    private let networkClient: NetworkClientProtocol
    private let favoritesRepository: FavoritesRepository
    private let configuration: AppConfiguration

    // MARK: - Cache

    private let memoryCache = MemoryCache<String, [CharacterEntity]>()
    private let diskCache = DiskCache<[Character]>(folderName: "CharactersCache")

    // MARK: - Request Deduplication

    private var inFlightRequests: [String: AnyPublisher<[CharacterEntity], DomainError>] = [:]
    private let requestLock = NSLock()

    // MARK: - Cache Keys

    private enum CacheKey {
        static func characters(page: Int) -> String { "characters_page_\(page)" }
        static func character(id: Int) -> String { "character_\(id)" }
        static func search(name: String, status: String?, species: String?, gender: String?, page: Int) -> String {
            "search_\(name)_\(status ?? "")_\(species ?? "")_\(gender ?? "")_page_\(page)"
        }
    }

    // MARK: - Initialization

    public init(
        networkClient: NetworkClientProtocol,
        favoritesRepository: FavoritesRepository,
        configuration: AppConfiguration = .shared
    ) {
        self.networkClient = networkClient
        self.favoritesRepository = favoritesRepository
        self.configuration = configuration
    }

    // MARK: - CharacterRepositoryProtocol Implementation

    public func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        let cacheKey = CacheKey.characters(page: page)

        // Check if request already in flight (deduplication)
        requestLock.lock()
        if let inFlight = inFlightRequests[cacheKey] {
            requestLock.unlock()
            return inFlight
        }
        requestLock.unlock()

        // L1: Check memory cache first
        if let cached = memoryCache.get(for: cacheKey), configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // L2: Check disk cache
        if configuration.isCachingEnabled,
           let diskData = try? diskCache.load(from: "page_\(page).json"),
           !diskData.isEmpty {
            let favoriteIds = getFavoriteIds()
            let entities = CharacterMapper.toDomain(diskData, favoriteIds: favoriteIds)

            // Promote to memory cache
            memoryCache.set(entities, for: cacheKey)

            return Just(entities)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // L3: Fetch from network
        let endpoint = FetchCharactersEndpoint(page: page)

        let publisher = networkClient
            .performRequest(endpoint, responseType: PagedResponse<Character>.self)
            .mapError { ErrorMapper.map($0) }
            .handleEvents(
                receiveOutput: { [weak self] response in
                    guard let self = self else { return }

                    // Cache the raw data to disk
                    if self.configuration.isCachingEnabled {
                        try? self.diskCache.save(response.results, as: "page_\(page).json")
                    }

                    // Map to domain entities with favorite status
                    let favoriteIds = self.getFavoriteIds()
                    let entities = CharacterMapper.toDomain(response.results, favoriteIds: favoriteIds)

                    // Cache in memory
                    if self.configuration.isCachingEnabled {
                        self.memoryCache.set(entities, for: cacheKey)
                    }
                },
                receiveCompletion: { [weak self] _ in
                    // Remove from in-flight requests
                    self?.requestLock.lock()
                    self?.inFlightRequests.removeValue(forKey: cacheKey)
                    self?.requestLock.unlock()
                }
            )
            .map { [weak self] response -> [CharacterEntity] in
                guard let self = self else { return [] }
                let favoriteIds = self.getFavoriteIds()
                return CharacterMapper.toDomain(response.results, favoriteIds: favoriteIds)
            }
            .share() // Share the publisher for multiple subscribers
            .eraseToAnyPublisher()

        // Store in-flight request
        requestLock.lock()
        inFlightRequests[cacheKey] = publisher
        requestLock.unlock()

        return publisher
    }

    public func fetchCharacter(by id: Int) -> AnyPublisher<CharacterEntity, DomainError> {
        let cacheKey = CacheKey.character(id: id)

        // Check memory cache
        if let cachedList = memoryCache.get(for: "all_characters"),
           let cached = cachedList.first(where: { $0.id == id }),
           configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from network
        let endpoint = FetchCharacterByIdEndpoint(id: id)

        return networkClient
            .performRequest(endpoint, responseType: Character.self)
            .mapError { ErrorMapper.map($0) }
            .map { [weak self] character -> CharacterEntity in
                let isFavorite = self?.isFavoriteSync(characterId: id) ?? false
                return CharacterMapper.toDomain(character, isFavorite: isFavorite)
            }
            .eraseToAnyPublisher()
    }

    public func searchCharacters(
        name: String,
        status: CharacterStatus?,
        species: String?,
        gender: CharacterGender?,
        page: Int
    ) -> AnyPublisher<[CharacterEntity], DomainError> {
        let statusString = status?.rawValue
        let genderString = gender?.rawValue
        let cacheKey = CacheKey.search(
            name: name,
            status: statusString,
            species: species,
            gender: genderString,
            page: page
        )

        // Check memory cache
        if let cached = memoryCache.get(for: cacheKey), configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from network
        let endpoint = SearchCharactersEndpoint(
            name: name,
            status: statusString,
            species: species,
            gender: genderString,
            page: page
        )

        return networkClient
            .performRequest(endpoint, responseType: PagedResponse<Character>.self)
            .mapError { ErrorMapper.map($0) }
            .map { [weak self] response -> [CharacterEntity] in
                guard let self = self else { return [] }

                let favoriteIds = self.getFavoriteIds()
                let entities = CharacterMapper.toDomain(response.results, favoriteIds: favoriteIds)

                // Cache in memory
                if self.configuration.isCachingEnabled {
                    self.memoryCache.set(entities, for: cacheKey)
                }

                return entities
            }
            .eraseToAnyPublisher()
    }

    public func getFavoriteCharacters() -> AnyPublisher<[CharacterEntity], DomainError> {
        let favoriteCharacters = favoritesRepository.favorites
        let entities = favoriteCharacters.map { character in
            CharacterMapper.toDomain(character, isFavorite: true)
        }

        return Just(entities)
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }

    public func toggleFavorite(characterId: Int) -> AnyPublisher<Bool, DomainError> {
        // Check if character is already in favorites
        let favoriteCharacter = favoritesRepository.favorites.first { $0.id == characterId }

        if let character = favoriteCharacter {
            // Character is in favorites, remove it
            favoritesRepository.toggleFavorite(character)
            memoryCache.clear()
            
            return Just(false)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        } else {
            // Need to fetch character from network to add to favorites
            return fetchCharacter(by: characterId)
                .tryMap { [weak self] (entity: CharacterEntity) throws -> Bool in
                    guard let self = self else { throw DomainError.unknownError }

                    // Convert entity to DTO for storage
                    let character = CharacterMapper.toDTO(entity)
                    
                    // Add to favorites
                    self.favoritesRepository.toggleFavorite(character)
                    
                    // Clear memory cache to refresh favorite status in UI
                    self.memoryCache.clear()
                    
                    return true
                }
                .mapError { error in
                    if let domainError = error as? DomainError {
                        return domainError
                    }
                    return DomainError.unknownError
                }
                .eraseToAnyPublisher()
        }
    }

    public func isFavorite(characterId: Int) -> AnyPublisher<Bool, DomainError> {
        let isFav = favoritesRepository.favorites.contains { $0.id == characterId }
        return Just(isFav)
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }

    // MARK: - Private Helpers

    private func getFavoriteIds() -> Set<Int> {
        Set(favoritesRepository.favorites.map { $0.id })
    }

    private func isFavoriteSync(characterId: Int) -> Bool {
        favoritesRepository.favorites.contains { $0.id == characterId }
    }
}
