//
//  CharacterEndpoints.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyNetworkInterface
import RickyConfiguration

/// Endpoint for fetching all characters with pagination
public struct FetchCharactersEndpoint: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let requestType: RequestType

    public init(page: Int = 1) {
        let config = AppConfiguration.shared.environment
        self.baseURL = config.baseURL
        self.path = "/character"
        self.method = .get
        self.headers = ["Accept": "application/json"]
        self.requestType = .query(["page": page])
    }
}

/// Endpoint for fetching a single character by ID
public struct FetchCharacterByIdEndpoint: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let requestType: RequestType

    public init(id: Int) {
        let config = AppConfiguration.shared.environment
        self.baseURL = config.baseURL
        self.path = "/character/\(id)"
        self.method = .get
        self.headers = ["Accept": "application/json"]
        self.requestType = .plain
    }
}

/// Endpoint for searching characters with filters
public struct SearchCharactersEndpoint: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let requestType: RequestType

    public init(
        name: String,
        status: String? = nil,
        species: String? = nil,
        gender: String? = nil,
        page: Int = 1
    ) {
        let config = AppConfiguration.shared.environment
        self.baseURL = config.baseURL
        self.path = "/character"
        self.method = .get
        self.headers = ["Accept": "application/json"]

        var parameters: [String: Any] = [
            "name": name,
            "page": page
        ]

        if let status = status {
            parameters["status"] = status
        }
        if let species = species {
            parameters["species"] = species
        }
        if let gender = gender {
            parameters["gender"] = gender
        }

        self.requestType = .query(parameters)
    }
}
