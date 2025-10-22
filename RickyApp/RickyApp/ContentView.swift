//
//  ContentView.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI
import RickyDesignSystem
import RickyRouter

struct ContentView: View {
    @StateObject private var router = RouterService.shared
    @State private var selectedTab: Tab = .characters
    
    enum Tab {
        case characters
        case favorites
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Characters Tab
            CharacterListView()
                .tabItem {
                    Label("Characters", systemImage: "person.3")
                }
                .tag(Tab.characters)
            
            // Favorites Tab
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)
        }
        .environmentObject(router)
    }
}

#Preview {
    ContentView()
}
