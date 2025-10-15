//
//  RequestBuilder.swift
//  RickyNetwork
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import RickyNetworkInterface

public struct RequestBuilder {
    public static func build(from endpoint: Endpoint) throws -> URLRequest {
        guard let url = URL(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }

        var request: URLRequest
        
        switch endpoint.requestType {
        case .plain:
            request = URLRequest(url: url)
        case .query(let parameters):
            var components = URLComponents(string: url.absoluteString)
            components?.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            guard let finalURL = components?.url else {
                throw NetworkError.invalidURL
            }
            request = URLRequest(url: finalURL)
        case .body(let data):
            request = URLRequest(url: url)
            request.httpBody = data
        }

        request.httpMethod = endpoint.method.rawValue
        endpoint.headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        return request
    }
}
