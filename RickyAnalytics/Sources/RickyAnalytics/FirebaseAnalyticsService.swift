//
//  FirebaseAnalyticsService.swift
//  RickyAnalytics
//
//  Created by Enes on 23.10.2025.
//

import Foundation
import FirebaseAnalytics

public final class FirebaseAnalyticsService: AnalyticsServiceProtocol, @unchecked Sendable {
    
    public static let shared = FirebaseAnalyticsService()
    
    private var isInitialized = false
    
    private init() {}
    
    public func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
    }
    
    public func logEvent(_ event: AnalyticsEvent) {
        guard isInitialized else {
            print("⚠️ Analytics not initialized. Call initialize() first.")
            return
        }
        
        Analytics.logEvent(event.name, parameters: event.parameters)
        
        #if DEBUG
        print("📊 Analytics Event: \(event.name)")
        if let params = event.parameters {
            print("   Parameters: \(params)")
        }
        #endif
    }
    
    public func setUserProperty(_ value: String, forName name: String) {
        guard isInitialized else { return }
        Analytics.setUserProperty(value, forName: name)
    }
    
    public func setUserID(_ userID: String?) {
        guard isInitialized else { return }
        Analytics.setUserID(userID)
    }
    
    public func setScreenName(_ screenName: String, screenClass: String?) {
        guard isInitialized else { return }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: screenClass ?? screenName
        ])
    }
}

