//
//  RickyAnalytics.swift
//  RickyAnalytics
//
//  Created by Enes on 23.10.2025.
//

import Foundation
@_exported import FirebaseAnalytics

public enum RickyAnalytics {
    public static var shared: AnalyticsServiceProtocol {
        return FirebaseAnalyticsService.shared
    }
}
