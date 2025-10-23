//
//  AnalyticsExtensions.swift
//  RickyAnalytics
//
//  Created by Enes on 23.10.2025.
//

import Foundation

public extension AnalyticsServiceProtocol {
    func testAnalytics() {
        logEvent(.screenView(screen: .characterList))
        logEvent(.characterViewed(characterId: 1, characterName: "Rick Sanchez"))
        logEvent(.characterAddedToFavorites(characterId: 1, characterName: "Rick Sanchez"))
        logEvent(.characterSearch(query: "Rick", resultsCount: 5))
        logEvent(.tabChanged(tab: .favorites))
        
        print("✅ Firebase Analytics test events sent!")
        print("📊 Check Firebase Console → Analytics → DebugView")
    }
}

