//
//  FetchLocationsUseCase.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

/// Parameters for fetching locations
public struct FetchLocationsParameters {
    public let page: Int
    public let refresh: Bool

    public init(page: Int, refresh: Bool = false) {
        self.page = page
        self.refresh = refresh
    }
}

/// Use case for fetching locations with pagination
public final class FetchLocationsUseCase: UseCaseProtocol {
    public typealias Parameters = FetchLocationsParameters
    public typealias ReturnType = [LocationEntity]
    public typealias ErrorType = DomainError

    private let repository: LocationRepositoryProtocol

    public init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(parameters: FetchLocationsParameters) -> AnyPublisher<[LocationEntity], DomainError> {
        return repository
            .fetchLocations(page: parameters.page)
            .handleEvents(receiveSubscription: { _ in
                // Log start of use case
                print("🎯 FetchLocationsUseCase: Starting to fetch locations for page \(parameters.page)")
            }, receiveOutput: { locations in
                // Log success
                print("✅ FetchLocationsUseCase: Successfully fetched \(locations.count) locations")
            }, receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    // Log error
                    print("❌ FetchLocationsUseCase: Failed with error: \(error)")
                }
            })
            .eraseToAnyPublisher()
    }
}
