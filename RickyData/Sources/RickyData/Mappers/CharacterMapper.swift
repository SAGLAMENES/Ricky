//
//  CharacterMapper.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyModel
import RickyDomain

/// Maps between Character model and CharacterEntity
public struct CharacterMapper {

    /// Converts Character (API model) to CharacterEntity (domain entity)
    /// - Parameters:
    ///   - character: The API model character
    ///   - isFavorite: Whether the character is marked as favorite
    /// - Returns: The corresponding domain entity
    public static func toDomain(_ character: Character, isFavorite: Bool = false) -> CharacterEntity {
        CharacterEntity(
            id: character.id,
            name: character.name,
            status: mapStatus(character.status),
            species: character.species,
            type: character.type,
            gender: mapGender(character.gender),
            origin: mapLocation(character.origin),
            location: mapLocation(character.location),
            imageURL: URL(string: character.image),
            episodeURLs: character.episode.compactMap { URL(string: $0) },
            profileURL: URL(string: character.url),
            createdDate: parseDate(character.created) ?? Date(),
            isFavorite: isFavorite
        )
    }

    /// Converts multiple characters to domain entities
    /// - Parameters:
    ///   - characters: Array of API model characters
    ///   - favoriteIds: Set of favorite character IDs
    /// - Returns: Array of domain entities
    public static func toDomain(_ characters: [Character], favoriteIds: Set<Int> = []) -> [CharacterEntity] {
        characters.map { character in
            toDomain(character, isFavorite: favoriteIds.contains(character.id))
        }
    }

    // MARK: - Private Mappers

    private static func mapStatus(_ status: String) -> CharacterStatus {
        CharacterStatus(rawValue: status) ?? .unknown
    }

    private static func mapGender(_ gender: String) -> CharacterGender {
        CharacterGender(rawValue: gender) ?? .unknown
    }

    private static func mapLocation(_ location: Location) -> LocationEntity {
        LocationMapper.toDomain(location)
    }

    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
