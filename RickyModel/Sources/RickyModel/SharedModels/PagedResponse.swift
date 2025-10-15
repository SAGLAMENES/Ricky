//
//  PagedResponse.swift
//  RickyModel
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public struct PagedResponse<T: Codable>: Codable {
    public let info: Info
    public let results: [T]
}