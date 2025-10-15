//
//  LocationDetail.swift
//  RickyModel
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

/// Detailed location information from API
public struct LocationDetail: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let type: String
    public let dimension: String
    public let residents: [String]
    public let url: String
    public let created: String

    public init(
        id: Int,
        name: String,
        type: String,
        dimension: String,
        residents: [String],
        url: String,
        created: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.dimension = dimension
        self.residents = residents
        self.url = url
        self.created = created
    }
}

/// Response for location list
public struct LocationResponse: Codable {
    public let info: Info
    public let results: [LocationDetail]

    public init(info: Info, results: [LocationDetail]) {
        self.info = info
        self.results = results
    }
}
