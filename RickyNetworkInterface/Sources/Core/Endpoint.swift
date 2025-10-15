//
//  Endpoint.swift
//  RickyNetworkInterface
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var requestType: RequestType { get }
}

public struct CharacterEndpoint: Endpoint {
    public let baseURL: String = "https://rickandmortyapi.com/api"
    public let path: String = "/character"
    public let method: HTTPMethod = .get
    public let headers: [String : String]? = ["Accept": "application/json"]
    public let requestType: RequestType = .plain

    public init() {}
}
