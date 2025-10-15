//
//  RickyData.swift
//  RickyData
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

/// RickyData module - Data layer implementation
///
/// This module contains:
/// - Repository implementations (CharacterRepository, LocationRepository)
/// - Data mappers (Model -> Entity conversions)
/// - Error mappers (NetworkError -> DomainError)
/// - API endpoints
/// - Caching strategies
///
/// Architecture:
/// - Implements domain layer protocols
/// - Uses network layer for API calls
/// - Uses persistence layer for caching
/// - Maps between data models and domain entities
public struct RickyData {
    public static let version = "1.0.0"
}
