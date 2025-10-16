//
//  Route.swift
//  RickyRouter
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import RickyDomain

/// All possible routes in the application.
///
/// `Route` provides type-safe navigation using Swift enums with associated values.
/// Each case represents a screen in the application, with compile-time safety for required data.
///
/// ## Overview
///
/// Use `Route` to define all possible navigation destinations in your app:
///
/// ```swift
/// // Navigate to character detail
/// router.navigate(to: .characterDetail(character))
///
/// // Navigate to location list
/// router.navigate(to: .locationList)
/// ```
///
/// ## Type Safety
///
/// Associated values ensure you provide required data at compile time:
///
/// ```swift
/// // ✅ Compiler enforces character parameter
/// router.navigate(to: .characterDetail(character))
///
/// // ❌ Won't compile without character
/// router.navigate(to: .characterDetail())
/// ```
///
/// ## Topics
///
/// ### Character Routes
/// - ``characterList``
/// - ``characterDetail(_:)``
///
/// ### Location Routes
/// - ``locationList``
/// - ``locationDetail(_:)``
///
/// ### Properties
/// - ``name``
/// - ``analyticsIdentifier``
public enum Route: Hashable {
    // MARK: - Character Routes

    /// Root screen showing character list.
    ///
    /// This is typically the app's main screen, showing a paginated list
    /// of Rick & Morty characters with search and filter capabilities.
    case characterList

    /// Character detail screen.
    ///
    /// Shows comprehensive information about a specific character including
    /// status, species, location, and episodes.
    ///
    /// - Parameter entity: The character to display
    case characterDetail(CharacterEntity)

    // MARK: - Location Routes

    /// Location list screen.
    ///
    /// Displays all locations from the Rick & Morty universe with
    /// pagination support.
    case locationList

    /// Location detail screen.
    ///
    /// Shows detailed information about a specific location including
    /// type, dimension, and residents.
    ///
    /// - Parameter entity: The location to display
    case locationDetail(LocationEntity)

    // MARK: - Helper Properties

    /// Human-readable route name for debugging.
    ///
    /// Returns a descriptive name for the route, useful for logging and debugging.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let route = Route.characterDetail(character)
    /// print(route.name) // "Character Detail"
    /// ```
    public var name: String {
        switch self {
        case .characterList:
            return "Character List"
        case .characterDetail:
            return "Character Detail"
        case .locationList:
            return "Location List"
        case .locationDetail:
            return "Location Detail"
        }
    }

    /// Analytics tracking identifier for screen view events.
    ///
    /// Returns a unique identifier suitable for analytics platforms like Firebase, Mixpanel, or Amplitude.
    /// Includes entity IDs for detail screens to enable user journey tracking.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let route = Route.characterDetail(character)
    /// Analytics.log(event: "screen_view", parameters: [
    ///     "screen": route.analyticsIdentifier
    /// ])
    /// // Logs: "screen_character_detail_1"
    /// ```
    ///
    /// ## Integration
    ///
    /// Use with your analytics service:
    ///
    /// ```swift
    /// router.$routeStack
    ///     .sink { stack in
    ///         if let current = stack.last {
    ///             Analytics.logScreenView(current.analyticsIdentifier)
    ///         }
    ///     }
    /// ```
    public var analyticsIdentifier: String {
        switch self {
        case .characterList:
            return "screen_character_list"
        case .characterDetail(let character):
            return "screen_character_detail_\(character.id)"
        case .locationList:
            return "screen_location_list"
        case .locationDetail(let location):
            return "screen_location_detail_\(location.id ?? 0)"
        }
    }
}
