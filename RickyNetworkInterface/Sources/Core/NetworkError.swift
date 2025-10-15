//
//  NetworkError.swift
//  RickyNetworkInterface
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingFailed
    case unknown(Error)
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let code):
            return "Request failed with status code \(code)."
        case .decodingFailed:
            return "Failed to decode the response."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}