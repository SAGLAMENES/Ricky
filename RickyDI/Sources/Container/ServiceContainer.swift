//
//  ServiceContainer.swift
//  RickyDI
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import RickyNetwork
import RickyPersistance
import RickyConfiguration
import RickyDomain
import RickyData

/// Central dependency injection container for the application
/// Manages creation and lifecycle of all services, repositories, and use cases
public final class ServiceContainer: @unchecked Sendable {
    public static let shared = ServiceContainer()

    // MARK: - Core Services

    public let configuration: Factory<AppConfiguration>
    public let networkClient: Factory<NetworkClient>

    // MARK: - Persistence

    public let favoritesRepository: Factory<FavoritesRepository>

    // MARK: - Repositories

    public let characterRepository: Factory<CharacterRepository>
    public let locationRepository: Factory<LocationRepository>

    // MARK: - Use Cases

    public let fetchCharactersUseCase: Factory<FetchCharactersUseCase>
    public let searchCharactersUseCase: Factory<SearchCharactersUseCase>
    public let toggleFavoriteUseCase: Factory<ToggleFavoriteUseCase>
    public let fetchLocationsUseCase: Factory<FetchLocationsUseCase>

    // MARK: - Initialization

    public init() {
        // Configuration
        self.configuration = Factory { AppConfiguration.shared }

        // Network
        self.networkClient = Factory { NetworkClient() }

        // Persistence
        self.favoritesRepository = Factory { FavoritesRepository() }

        // Repositories
        self.characterRepository = Factory {
            CharacterRepository(
                networkClient: ServiceContainer.shared.networkClient.resolve(),
                favoritesRepository: ServiceContainer.shared.favoritesRepository.resolve()
            )
        }

        self.locationRepository = Factory {
            LocationRepository(
                networkClient: ServiceContainer.shared.networkClient.resolve()
            )
        }

        // Use Cases
        self.fetchCharactersUseCase = Factory {
            FetchCharactersUseCase(
                characterRepository: ServiceContainer.shared.characterRepository.resolve()
            )
        }

        self.searchCharactersUseCase = Factory {
            SearchCharactersUseCase(
                characterRepository: ServiceContainer.shared.characterRepository.resolve()
            )
        }

        self.toggleFavoriteUseCase = Factory {
            ToggleFavoriteUseCase(
                characterRepository: ServiceContainer.shared.characterRepository.resolve()
            )
        }

        self.fetchLocationsUseCase = Factory {
            FetchLocationsUseCase(
                repository: ServiceContainer.shared.locationRepository.resolve()
            )
        }
    }

    // MARK: - Convenience Methods

    /// Reset all singletons (useful for testing)
    public func reset() {
        // Clear caches
        // Reset configurations
        // Re-initialize services if needed
    }
}
