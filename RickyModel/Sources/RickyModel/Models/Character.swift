//
//  Character.swift
//  RickyModel
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public struct CharacterResponse: Codable {
    public let info: Info
    public let results: [Character]
}

public struct Character: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let type: String
    public let gender: String
    public let origin: Origin
    public let location: Location
    public let image: String
    public let episode: [String]
    public let url: String
    public let created: String
}
