//
//  DomainError.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public enum DomainError: LocalizedError, Equatable {
    case networkUnavailable
    case dataCorrupted
    case unauthorized
    case notFound
    case serverError(String)
    case unknownError
    case validationError(String)
    case cacheError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return NSLocalizedString("Network is not available. Please check your internet connection.", comment: "Network error")
        case .dataCorrupted:
            return NSLocalizedString("The data received is corrupted or invalid.", comment: "Data corruption error")
        case .unauthorized:
            return NSLocalizedString("You are not authorized to perform this action.", comment: "Authorization error")
        case .notFound:
            return NSLocalizedString("The requested resource was not found.", comment: "Not found error")
        case .serverError(let message):
            return String(format: NSLocalizedString("Server error: %@", comment: "Server error"), message)
        case .unknownError:
            return NSLocalizedString("An unknown error occurred. Please try again.", comment: "Unknown error")
        case .validationError(let message):
            return String(format: NSLocalizedString("Validation error: %@", comment: "Validation error"), message)
        case .cacheError(let message):
            return String(format: NSLocalizedString("Cache error: %@", comment: "Cache error"), message)
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection"
        case .dataCorrupted:
            return "Invalid data format"
        case .unauthorized:
            return "Authentication required"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server returned an error"
        case .unknownError:
            return "Unexpected error"
        case .validationError:
            return "Input validation failed"
        case .cacheError:
            return "Cache operation failed"
        }
    }
}