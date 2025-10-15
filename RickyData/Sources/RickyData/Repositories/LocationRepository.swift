//
//  LocationRepository.swift
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

/// Implementation of LocationRepositoryProtocol
/// Handles location data fetching with caching strategy
public final class LocationRepository: LocationRepositoryProtocol {

    // MARK: - Dependencies

    private let networkClient: NetworkClientProtocol
    private let configuration: AppConfiguration

    // MARK: - Cache

    private let memoryCache = MemoryCache<String, [LocationEntity]>()
    private let diskCache = DiskCache<[LocationDetail]>(folderName: "LocationsCache")

    // MARK: - Cache Keys

    private enum CacheKey {
        static func locations(page: Int) -> String { "locations_page_\(page)" }
        static func location(id: Int) -> String { "location_\(id)" }
        static func search(name: String, type: String?, dimension: String?, page: Int) -> String {
            "search_\(name)_\(type ?? "")_\(dimension ?? "")_page_\(page)"
        }
    }

    // MARK: - Initialization

    public init(
        networkClient: NetworkClientProtocol,
        configuration: AppConfiguration = .shared
    ) {
        self.networkClient = networkClient
        self.configuration = configuration
    }

    // MARK: - LocationRepositoryProtocol Implementation

    public func fetchLocations(page: Int) -> AnyPublisher<[LocationEntity], DomainError> {
        let cacheKey = CacheKey.locations(page: page)

        // Check memory cache first
        if let cached = memoryCache.get(for: cacheKey), configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from network
        let endpoint = FetchLocationsEndpoint(page: page)

        return networkClient
            .performRequest(endpoint, responseType: PagedResponse<LocationDetail>.self)
            .mapError { ErrorMapper.map($0) }
            .map { [weak self] response -> [LocationEntity] in
                guard let self = self else { return [] }

                // Cache the raw data to disk
                if self.configuration.isCachingEnabled {
                    try? self.diskCache.save(response.results, as: "page_\(page).json")
                }

                // Map to domain entities
                let entities = LocationMapper.toDomain(response.results)

                // Cache in memory
                if self.configuration.isCachingEnabled {
                    self.memoryCache.set(entities, for: cacheKey)
                }

                return entities
            }
            .eraseToAnyPublisher()
    }

    public func fetchLocation(by id: Int) -> AnyPublisher<LocationEntity, DomainError> {
        let cacheKey = CacheKey.location(id: id)

        // Check memory cache
        if let cachedList = memoryCache.get(for: "all_locations"),
           let cached = cachedList.first(where: { $0.id == id }),
           configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from network
        let endpoint = FetchLocationByIdEndpoint(id: id)

        return networkClient
            .performRequest(endpoint, responseType: LocationDetail.self)
            .mapError { ErrorMapper.map($0) }
            .map { location -> LocationEntity in
                LocationMapper.toDomain(location)
            }
            .eraseToAnyPublisher()
    }

    public func searchLocations(
        name: String,
        type: String?,
        dimension: String?,
        page: Int
    ) -> AnyPublisher<[LocationEntity], DomainError> {
        let cacheKey = CacheKey.search(
            name: name,
            type: type,
            dimension: dimension,
            page: page
        )

        // Check memory cache
        if let cached = memoryCache.get(for: cacheKey), configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // Fetch from network
        let endpoint = SearchLocationsEndpoint(
            name: name,
            type: type,
            dimension: dimension,
            page: page
        )

        return networkClient
            .performRequest(endpoint, responseType: PagedResponse<LocationDetail>.self)
            .mapError { ErrorMapper.map($0) }
            .map { [weak self] response -> [LocationEntity] in
                guard let self = self else { return [] }

                // Map to domain entities
                let entities = LocationMapper.toDomain(response.results)

                // Cache in memory
                if self.configuration.isCachingEnabled {
                    self.memoryCache.set(entities, for: cacheKey)
                }

                return entities
            }
            .eraseToAnyPublisher()
    }
}
