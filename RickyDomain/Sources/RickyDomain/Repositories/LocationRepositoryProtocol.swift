//
//  LocationRepositoryProtocol.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

/// Protocol for location data operations
public protocol LocationRepositoryProtocol {
    /// Fetch paginated list of locations
    func fetchLocations(page: Int) -> AnyPublisher<[LocationEntity], DomainError>

    /// Fetch single location by ID
    func fetchLocation(by id: Int) -> AnyPublisher<LocationEntity, DomainError>
}
