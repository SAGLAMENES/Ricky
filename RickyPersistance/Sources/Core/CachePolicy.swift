//
//  CachePolicy.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

/// Defines cache expiration and invalidation policies
public struct CachePolicy: Sendable {
    /// Time to live for cached data (in seconds)
    public let ttl: TimeInterval

    /// Maximum number of items to keep in cache
    public let maxItems: Int?

    /// Maximum cache size in bytes
    public let maxSize: Int?

    public init(
        ttl: TimeInterval = 3600, // 1 hour default
        maxItems: Int? = nil,
        maxSize: Int? = nil
    ) {
        self.ttl = ttl
        self.maxItems = maxItems
        self.maxSize = maxSize
    }

    /// Predefined cache policies
    public static let short = CachePolicy(ttl: 300) // 5 minutes
    public static let medium = CachePolicy(ttl: 3600) // 1 hour
    public static let long = CachePolicy(ttl: 86400) // 24 hours
    public static let permanent = CachePolicy(ttl: .infinity)
}

/// Strategy for cache behavior
public enum CacheStrategy: Sendable {
    /// Always fetch from network, cache the result
    case networkFirst

    /// Use cache if available, fallback to network
    case cacheFirst

    /// Use cache only, never fetch from network
    case cacheOnly

    /// Always fetch from network, don't use cache
    case networkOnly

    /// Fetch from network and cache simultaneously, return cache first if available
    case parallel
}

/// Entry wrapper with metadata for cached items
public struct CacheEntry<Value>: @unchecked Sendable {
    public let value: Value
    public let timestamp: Date
    public let expiresAt: Date

    public init(value: Value, policy: CachePolicy) {
        self.value = value
        self.timestamp = Date()
        self.expiresAt = Date().addingTimeInterval(policy.ttl)
    }

    public var isExpired: Bool {
        Date() > expiresAt
    }

    public var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }
}
