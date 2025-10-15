//
//  ErrorMapper.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyNetworkInterface
import RickyDomain

/// Maps network layer errors to domain layer errors
public struct ErrorMapper {

    /// Converts NetworkError to DomainError
    /// - Parameter networkError: The network error to convert
    /// - Returns: Corresponding domain error
    public static func map(_ networkError: NetworkError) -> DomainError {
        switch networkError {
        case .invalidURL:
            return .validationError("Invalid URL format")

        case .requestFailed(let statusCode):
            return mapHTTPStatusCode(statusCode)

        case .decodingFailed:
            return .dataCorrupted

        case .unknown(let error):
            if let urlError = error as? URLError {
                return mapURLError(urlError)
            }
            return .unknownError
        }
    }

    /// Maps HTTP status codes to domain errors
    private static func mapHTTPStatusCode(_ code: Int) -> DomainError {
        switch code {
        case 401, 403:
            return .unauthorized
        case 404:
            return .notFound
        case 500...599:
            return .serverError("Server error with status code: \(code)")
        default:
            return .serverError("Request failed with status code: \(code)")
        }
    }

    /// Maps URLError to domain errors
    private static func mapURLError(_ error: URLError) -> DomainError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .timedOut:
            return .serverError("Request timed out")
        case .cannotFindHost, .cannotConnectToHost:
            return .serverError("Cannot connect to server")
        default:
            return .unknownError
        }
    }
}
