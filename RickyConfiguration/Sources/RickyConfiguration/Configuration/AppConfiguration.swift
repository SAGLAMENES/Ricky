//
//  AppConfiguration.swift
//  RickyConfiguration
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public final class AppConfiguration: @unchecked Sendable {
    public static let shared = AppConfiguration()
    
    public private(set) var environment: EnvironmentConfiguration
    public private(set) var featureFlags: FeatureFlagProvider
    
    private init() {
        // Determine environment from build configuration
        #if DEBUG
        self.environment = .development
        #elseif STAGING
        self.environment = .staging
        #else
        self.environment = .production
        #endif
        
        self.featureFlags = FeatureFlagManager.shared
        setupFeatureFlagsForEnvironment()
    }
    
    // MARK: - Public Methods
    
    public func configure(with environment: EnvironmentConfiguration) {
        self.environment = environment
        setupFeatureFlagsForEnvironment()
    }
    
    public func configure(with featureFlagProvider: FeatureFlagProvider) {
        self.featureFlags = featureFlagProvider
    }
    
    // MARK: - Convenience Methods
    
    public var isDebugMode: Bool {
        environment.debugLoggingEnabled
    }
    
    public var isCachingEnabled: Bool {
        environment.cachingEnabled
    }
    
    public func isFeatureEnabled(_ feature: FeatureFlag) -> Bool {
        featureFlags.isEnabled(feature)
    }
    
    // MARK: - Private Methods
    
    private func setupFeatureFlagsForEnvironment() {
        if let featureFlagManager = featureFlags as? FeatureFlagManager {
            featureFlagManager.setupForEnvironment(environment.environment)
        }
    }
}

// MARK: - Environment Detection
private extension AppConfiguration {
    var currentEnvironment: AppEnvironment {
        // Check for environment override from launch arguments or environment variables
        if let environmentString = ProcessInfo.processInfo.environment["RICKY_ENVIRONMENT"],
           let environment = AppEnvironment(rawValue: environmentString) {
            return environment
        }
        
        // Check launch arguments
        if ProcessInfo.processInfo.arguments.contains("--staging") {
            return .staging
        }
        
        if ProcessInfo.processInfo.arguments.contains("--production") {
            return .production
        }
        
        // Default to development for debug builds
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}