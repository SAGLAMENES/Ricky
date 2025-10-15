//
//  Location.swift
//  RickyModel
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public struct Location: Codable {
    public let name: String
    public let url: String
}

public typealias Origin = Location