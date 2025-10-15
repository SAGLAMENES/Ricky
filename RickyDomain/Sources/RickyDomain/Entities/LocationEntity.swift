//
//  LocationEntity.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public struct LocationEntity: Hashable {
    public let id: Int?
    public let name: String
    public let url: URL?
    public let type: String?
    public let dimension: String?
    public let residentURLs: [URL]?
    public let createdDate: Date?

    // Hashable conformance
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(url)
    }

    public static func == (lhs: LocationEntity, rhs: LocationEntity) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name
    }

    public init(
        id: Int? = nil,
        name: String,
        url: URL?,
        type: String? = nil,
        dimension: String? = nil,
        residentURLs: [URL]? = nil,
        createdDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
        self.dimension = dimension
        self.residentURLs = residentURLs
        self.createdDate = createdDate
    }
}

// MARK: - Business Logic Extensions
public extension LocationEntity {
    var isUnknown: Bool {
        name.lowercased() == "unknown"
    }

    var displayName: String {
        isUnknown ? "Unknown Location" : name
    }

    var residentCount: Int {
        residentURLs?.count ?? 0
    }

    var displayType: String {
        type ?? "Unknown Type"
    }

    var displayDimension: String {
        dimension ?? "Unknown Dimension"
    }

    var hasResidents: Bool {
        residentCount > 0
    }

    static var unknown: LocationEntity {
        LocationEntity(name: "unknown", url: nil)
    }
}