//
//  FeatureFlags.swift
//  RickyConfiguration
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public enum FeatureFlag: String, CaseIterable {
    case newCharacterDetailsUI = "new_character_details_ui"
    case enhancedSearch = "enhanced_search"
    case offlineMode = "offline_mode"
    case pushNotifications = "push_notifications"
    case advancedFiltering = "advanced_filtering"
    case socialSharing = "social_sharing"
    case darkModeSupport = "dark_mode_support"
    case premiumFeatures = "premium_features"
    
    public var description: String {
        switch self {
        case .newCharacterDetailsUI:
            return "New Character Details UI"
        case .enhancedSearch:
            return "Enhanced Search Functionality"
        case .offlineMode:
            return "Offline Mode Support"
        case .pushNotifications:
            return "Push Notifications"
        case .advancedFiltering:
            return "Advanced Filtering Options"
        case .socialSharing:
            return "Social Media Sharing"
        case .darkModeSupport:
            return "Dark Mode Support"
        case .premiumFeatures:
            return "Premium Features Access"
        }
    }
    
    public var defaultValue: Bool {
        switch self {
        case .newCharacterDetailsUI: return false
        case .enhancedSearch: return true
        case .offlineMode: return false
        case .pushNotifications: return true
        case .advancedFiltering: return true
        case .socialSharing: return false
        case .darkModeSupport: return true
        case .premiumFeatures: return false
        }
    }
}

public protocol FeatureFlagProvider {
    func isEnabled(_ feature: FeatureFlag) -> Bool
    func setEnabled(_ enabled: Bool, for feature: FeatureFlag)
    func reset()
    func getAllFlags() -> [FeatureFlag: Bool]
}

public final class FeatureFlagManager: FeatureFlagProvider, @unchecked Sendable {
    public static let shared = FeatureFlagManager()
    
    private let userDefaults: UserDefaults
    private let keyPrefix = "feature_flag_"
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    public func isEnabled(_ feature: FeatureFlag) -> Bool {
        let key = keyPrefix + feature.rawValue
        if userDefaults.object(forKey: key) == nil {
            // If not set, use default value
            setEnabled(feature.defaultValue, for: feature)
            return feature.defaultValue
        }
        return userDefaults.bool(forKey: key)
    }
    
    public func setEnabled(_ enabled: Bool, for feature: FeatureFlag) {
        let key = keyPrefix + feature.rawValue
        userDefaults.set(enabled, forKey: key)
        
        // Post notification for observers
        NotificationCenter.default.post(
            name: .featureFlagDidChange,
            object: nil,
            userInfo: [
                "feature": feature,
                "enabled": enabled
            ]
        )
    }
    
    public func reset() {
        FeatureFlag.allCases.forEach { feature in
            setEnabled(feature.defaultValue, for: feature)
        }
    }
    
    public func getAllFlags() -> [FeatureFlag: Bool] {
        var flags: [FeatureFlag: Bool] = [:]
        FeatureFlag.allCases.forEach { feature in
            flags[feature] = isEnabled(feature)
        }
        return flags
    }
}

// MARK: - Environment-based Feature Flags
public extension FeatureFlagManager {
    func setupForEnvironment(_ environment: AppEnvironment) {
        switch environment {
        case .development:
            setEnabled(true, for: .newCharacterDetailsUI)
            setEnabled(true, for: .enhancedSearch)
            setEnabled(true, for: .advancedFiltering)
        case .staging:
            setEnabled(false, for: .newCharacterDetailsUI)
            setEnabled(true, for: .enhancedSearch)
            setEnabled(true, for: .advancedFiltering)
        case .production:
            setEnabled(false, for: .newCharacterDetailsUI)
            setEnabled(true, for: .enhancedSearch)
            setEnabled(false, for: .advancedFiltering)
        }
    }
}

// MARK: - Notifications
public extension Notification.Name {
    static let featureFlagDidChange = Notification.Name("featureFlagDidChange")
}