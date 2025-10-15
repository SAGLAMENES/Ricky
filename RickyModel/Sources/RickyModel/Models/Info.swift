//
//  Info.swift
//  RickyModel
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public struct Info: Codable {
    public let count: Int
    public let pages: Int
    public let next: String?
    public let prev: String?
}