//
//  LocationEndpoints.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyNetworkInterface
import RickyConfiguration

/// Endpoint for fetching all locations with pagination
public struct FetchLocationsEndpoint: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let requestType: RequestType

    public init(page: Int = 1) {
        let config = AppConfiguration.shared.environment
        self.baseURL = config.baseURL
        self.path = "/location"
        self.method = .get
        self.headers = ["Accept": "application/json"]
        self.requestType = .query(["page": page])
    }
}

/// Endpoint for fetching a single location by ID
public struct FetchLocationByIdEndpoint: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let requestType: RequestType

    public init(id: Int) {
        let config = AppConfiguration.shared.environment
        self.baseURL = config.baseURL
        self.path = "/location/\(id)"
        self.method = .get
        self.headers = ["Accept": "application/json"]
        self.requestType = .plain
    }
}

/// Endpoint for searching locations with filters
public struct SearchLocationsEndpoint: Endpoint {
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    public let requestType: RequestType

    public init(
        name: String,
        type: String? = nil,
        dimension: String? = nil,
        page: Int = 1
    ) {
        let config = AppConfiguration.shared.environment
        self.baseURL = config.baseURL
        self.path = "/location"
        self.method = .get
        self.headers = ["Accept": "application/json"]

        var parameters: [String: Any] = [
            "name": name,
            "page": page
        ]

        if let type = type {
            parameters["type"] = type
        }
        if let dimension = dimension {
            parameters["dimension"] = dimension
        }

        self.requestType = .query(parameters)
    }
}
