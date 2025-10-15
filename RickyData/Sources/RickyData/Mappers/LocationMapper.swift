//
//  LocationMapper.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyModel
import RickyDomain

/// Maps between Location models and LocationEntity
public struct LocationMapper {

    /// Converts LocationDetail (API model) to LocationEntity (domain entity)
    /// - Parameter location: The API model location
    /// - Returns: The corresponding domain entity
    public static func toDomain(_ location: LocationDetail) -> LocationEntity {
        LocationEntity(
            id: location.id,
            name: location.name,
            url: URL(string: location.url),
            type: location.type,
            dimension: location.dimension,
            residentURLs: location.residents.compactMap { URL(string: $0) },
            createdDate: parseDate(location.created)
        )
    }

    /// Converts multiple location details to domain entities
    /// - Parameter locations: Array of API model locations
    /// - Returns: Array of domain entities
    public static func toDomain(_ locations: [LocationDetail]) -> [LocationEntity] {
        locations.map { toDomain($0) }
    }

    /// Converts simple Location (used in Character) to LocationEntity
    /// - Parameter location: The simple location model
    /// - Returns: The corresponding domain entity
    public static func toDomain(_ location: Location) -> LocationEntity {
        LocationEntity(
            id: nil,
            name: location.name,
            url: URL(string: location.url)
        )
    }

    // MARK: - Private Helpers

    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
