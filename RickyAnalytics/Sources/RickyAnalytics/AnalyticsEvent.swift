//
//  AnalyticsEvent.swift
//  RickyAnalytics
//
//  Created by Enes on 23.10.2025.
//

import Foundation

public enum AnalyticsEvent {
    case screenView(screen: Screen)
    case characterViewed(characterId: Int, characterName: String)
    case characterAddedToFavorites(characterId: Int, characterName: String)
    case characterRemovedFromFavorites(characterId: Int, characterName: String)
    case characterSearch(query: String, resultsCount: Int)
    case locationViewed(locationId: Int, locationName: String)
    case tabChanged(tab: TabType)
    case apiError(endpoint: String, errorCode: String)
    case custom(name: String, parameters: [String: Any]?)
    
    public var name: String {
        switch self {
        case .screenView:
            return "screen_view"
        case .characterViewed:
            return "character_viewed"
        case .characterAddedToFavorites:
            return "character_added_to_favorites"
        case .characterRemovedFromFavorites:
            return "character_removed_from_favorites"
        case .characterSearch:
            return "character_search"
        case .locationViewed:
            return "location_viewed"
        case .tabChanged:
            return "tab_changed"
        case .apiError:
            return "api_error"
        case .custom(let name, _):
            return name
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .screenView(let screen):
            return [
                "screen_name": screen.rawValue,
                "screen_class": screen.screenClass
            ]
            
        case .characterViewed(let characterId, let characterName):
            return [
                "character_id": characterId,
                "character_name": characterName
            ]
            
        case .characterAddedToFavorites(let characterId, let characterName):
            return [
                "character_id": characterId,
                "character_name": characterName,
                "action": "add"
            ]
            
        case .characterRemovedFromFavorites(let characterId, let characterName):
            return [
                "character_id": characterId,
                "character_name": characterName,
                "action": "remove"
            ]
            
        case .characterSearch(let query, let resultsCount):
            return [
                "search_query": query,
                "results_count": resultsCount
            ]
            
        case .locationViewed(let locationId, let locationName):
            return [
                "location_id": locationId,
                "location_name": locationName
            ]
            
        case .tabChanged(let tab):
            return [
                "tab_name": tab.rawValue
            ]
            
        case .apiError(let endpoint, let errorCode):
            return [
                "endpoint": endpoint,
                "error_code": errorCode
            ]
            
        case .custom(_, let parameters):
            return parameters
        }
    }
}

public enum Screen: String {
    case characterList = "character_list"
    case characterDetail = "character_detail"
    case favorites = "favorites"
    case locationList = "location_list"
    case locationDetail = "location_detail"
    
    var screenClass: String {
        switch self {
        case .characterList:
            return "CharacterListView"
        case .characterDetail:
            return "CharacterDetailView"
        case .favorites:
            return "FavoritesView"
        case .locationList:
            return "LocationListView"
        case .locationDetail:
            return "LocationDetailView"
        }
    }
}

public enum TabType: String {
    case characters
    case favorites
    case locations
}

