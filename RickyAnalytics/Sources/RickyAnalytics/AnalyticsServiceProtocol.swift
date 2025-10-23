//
//  AnalyticsServiceProtocol.swift
//  RickyAnalytics
//
//  Created by Enes on 23.10.2025.
//

import Foundation

public protocol AnalyticsServiceProtocol {
    func initialize()
    
    func logEvent(_ event: AnalyticsEvent)
    
    func setUserProperty(_ value: String, forName name: String)
    
    func setUserID(_ userID: String?)
    
    func setScreenName(_ screenName: String, screenClass: String?)
}

