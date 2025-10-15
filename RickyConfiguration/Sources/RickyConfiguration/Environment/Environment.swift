//
//  Environment.swift
//  RickyConfiguration
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public enum AppEnvironment: String, CaseIterable, Sendable {
    case development = "development"
    case staging = "staging" 
    case production = "production"
    
    public var displayName: String {
        switch self {
        case .development: return "Development"
        case .staging: return "Staging"
        case .production: return "Production"
        }
    }
}

public protocol EnvironmentConfigurable {
    var baseURL: String { get }
    var apiVersion: String { get }
    var timeout: TimeInterval { get }
    var allowsInsecureConnections: Bool { get }
    var debugLoggingEnabled: Bool { get }
    var cachingEnabled: Bool { get }
    var maxCacheSize: Int { get }
}

public struct EnvironmentConfiguration: EnvironmentConfigurable, Sendable {
    public let environment: AppEnvironment
    public let baseURL: String
    public let apiVersion: String
    public let timeout: TimeInterval
    public let allowsInsecureConnections: Bool
    public let debugLoggingEnabled: Bool
    public let cachingEnabled: Bool
    public let maxCacheSize: Int
    
    public init(
        environment: AppEnvironment,
        baseURL: String,
        apiVersion: String = "v1",
        timeout: TimeInterval = 30.0,
        allowsInsecureConnections: Bool = false,
        debugLoggingEnabled: Bool = false,
        cachingEnabled: Bool = true,
        maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
    ) {
        self.environment = environment
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.timeout = timeout
        self.allowsInsecureConnections = allowsInsecureConnections
        self.debugLoggingEnabled = debugLoggingEnabled
        self.cachingEnabled = cachingEnabled
        self.maxCacheSize = maxCacheSize
    }
}

// MARK: - Predefined Environments
public extension EnvironmentConfiguration {
    static let development = EnvironmentConfiguration(
        environment: .development,
        baseURL: "https://rickandmortyapi.com/api",
        allowsInsecureConnections: true,
        debugLoggingEnabled: true
    )
    
    static let staging = EnvironmentConfiguration(
        environment: .staging,
        baseURL: "https://staging-rickandmortyapi.com/api",
        debugLoggingEnabled: true
    )
    
    static let production = EnvironmentConfiguration(
        environment: .production,
        baseURL: "https://rickandmortyapi.com/api",
        debugLoggingEnabled: false
    )
}