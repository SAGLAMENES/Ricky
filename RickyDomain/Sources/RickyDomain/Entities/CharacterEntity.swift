//
//  CharacterEntity.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyModel

// Domain entity that encapsulates business logic
public struct CharacterEntity: Hashable, Identifiable {
    public let id: Int
    public let name: String
    public let status: CharacterStatus
    public let species: String
    public let type: String
    public let gender: CharacterGender
    public let origin: LocationEntity
    public let location: LocationEntity
    public let imageURL: URL?
    public let episodeURLs: [URL]
    public let profileURL: URL?
    public let createdDate: Date
    public var isFavorite: Bool

    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: CharacterEntity, rhs: CharacterEntity) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(
        id: Int,
        name: String,
        status: CharacterStatus,
        species: String,
        type: String,
        gender: CharacterGender,
        origin: LocationEntity,
        location: LocationEntity,
        imageURL: URL?,
        episodeURLs: [URL],
        profileURL: URL?,
        createdDate: Date,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.origin = origin
        self.location = location
        self.imageURL = imageURL
        self.episodeURLs = episodeURLs
        self.profileURL = profileURL
        self.createdDate = createdDate
        self.isFavorite = isFavorite
    }
}

// MARK: - Business Logic Extensions
public extension CharacterEntity {
    var isAlive: Bool {
        status == .alive
    }
    
    var isDead: Bool {
        status == .dead
    }
    
    var displayStatus: String {
        "\(status.rawValue.capitalized) - \(species)"
    }
    
    var episodeCount: Int {
        episodeURLs.count
    }
    
    var hasUnknownOrigin: Bool {
        origin.isUnknown
    }
    
    var isFromEarth: Bool {
        origin.name.lowercased().contains("earth")
    }

    /// Creates a copy of this entity with updated favorite status
    func withFavorite(_ isFavorite: Bool) -> CharacterEntity {
        CharacterEntity(
            id: self.id,
            name: self.name,
            status: self.status,
            species: self.species,
            type: self.type,
            gender: self.gender,
            origin: self.origin,
            location: self.location,
            imageURL: self.imageURL,
            episodeURLs: self.episodeURLs,
            profileURL: self.profileURL,
            createdDate: self.createdDate,
            isFavorite: isFavorite
        )
    }
}

// MARK: - Status Enum
public enum CharacterStatus: String, CaseIterable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"
    
    public var displayColor: String {
        switch self {
        case .alive: return "green"
        case .dead: return "red"  
        case .unknown: return "gray"
        }
    }
}

// MARK: - Gender Enum
public enum CharacterGender: String, CaseIterable {
    case female = "Female"
    case male = "Male"
    case genderless = "Genderless"
    case unknown = "unknown"
}