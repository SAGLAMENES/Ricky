//
//  RickyAppApp.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI
import RickyDesignSystem
import RickyDI
import FirebaseCore

@main
struct RickyAppApp: App {
    
    init() {
        setupFirebase()
        setupAnalytics()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupAnalytics() {
        let analytics = ServiceContainer.shared.analyticsService.resolve()
        analytics.initialize()
    }
}
