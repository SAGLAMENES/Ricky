//
//  MemoryCache.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Thread-safe in-memory cache with LRU eviction and expiration support
public final class MemoryCache<Key: Hashable, Value> {
    private var cache: [Key: CacheEntry<Value>] = [:]
    private var accessOrder: [Key] = [] // LRU tracking: first = least recent, last = most recent
    private let lock = NSLock()
    private let policy: CachePolicy

    // Metrics
    private var hitCount: Int = 0
    private var missCount: Int = 0

    public init(policy: CachePolicy = .medium) {
        self.policy = policy
        setupMemoryWarningObserver()
    }

    deinit {
        #if canImport(UIKit)
        NotificationCenter.default.removeObserver(self)
        #endif
    }

    // MARK: - Setup

    private func setupMemoryWarningObserver() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
    }

    /// Store a value in cache with LRU tracking
    public func set(_ value: Value, for key: Key, policy: CachePolicy? = nil) {
        lock.lock()
        defer { lock.unlock() }

        let cachePolicy = policy ?? self.policy
        cache[key] = CacheEntry(value: value, policy: cachePolicy)

        // Update LRU access order
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)

        // Enforce max items limit with LRU eviction
        if let maxItems = cachePolicy.maxItems, cache.count > maxItems {
            evictLRU(keepCount: maxItems)
        }
    }

    /// Retrieve a value from cache
    /// Returns nil if not found or expired
    /// Updates LRU access order
    public func get(for key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }

        guard let entry = cache[key] else {
            missCount += 1
            return nil
        }

        // Check expiration
        if entry.isExpired {
            removeEntry(for: key)
            missCount += 1
            return nil
        }

        // Update LRU access order (move to end = most recent)
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
        accessOrder.append(key)

        hitCount += 1
        return entry.value
    }

    /// Remove a specific key from cache
    public func remove(for key: Key) {
        lock.lock()
        defer { lock.unlock() }
        removeEntry(for: key)
    }

    /// Clear all cached values
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        cache.removeAll()
        accessOrder.removeAll()
        hitCount = 0
        missCount = 0
    }

    /// Remove all expired entries
    public func cleanupExpired() {
        lock.lock()
        defer { lock.unlock() }

        let expiredKeys = cache.filter { $0.value.isExpired }.map { $0.key }
        expiredKeys.forEach { cache.removeValue(forKey: $0) }
    }

    /// Get cache statistics
    public var statistics: CacheStatistics {
        lock.lock()
        defer { lock.unlock() }

        let totalCount = cache.count
        let expiredCount = cache.values.filter { $0.isExpired }.count

        return CacheStatistics(
            totalItems: totalCount,
            expiredItems: expiredCount,
            validItems: totalCount - expiredCount,
            hitCount: hitCount,
            missCount: missCount,
            hitRate: calculateHitRate()
        )
    }

    // MARK: - Private Methods

    /// Remove entry and update access order
    private func removeEntry(for key: Key) {
        cache.removeValue(forKey: key)
        if let index = accessOrder.firstIndex(of: key) {
            accessOrder.remove(at: index)
        }
    }

    /// Evict least recently used items
    private func evictLRU(keepCount: Int) {
        let itemsToRemove = cache.count - keepCount
        guard itemsToRemove > 0 else { return }

        // Remove least recently used items (from beginning of accessOrder)
        let keysToRemove = Array(accessOrder.prefix(itemsToRemove))
        keysToRemove.forEach { removeEntry(for: $0) }
    }

    /// Calculate cache hit rate
    private func calculateHitRate() -> Double {
        let total = hitCount + missCount
        guard total > 0 else { return 0 }
        return Double(hitCount) / Double(total)
    }

    /// Handle memory warning from system
    @objc private func handleMemoryWarning() {
        lock.lock()
        defer { lock.unlock() }

        // Clear 50% of cache on memory warning
        let halfCount = cache.count / 2
        if halfCount > 0 {
            evictLRU(keepCount: halfCount)
        }

        #if DEBUG
        print("⚠️ Memory warning: Cleared \(cache.count - halfCount) cache entries")
        #endif
    }
}

/// Cache statistics with hit/miss tracking
public struct CacheStatistics {
    public let totalItems: Int
    public let expiredItems: Int
    public let validItems: Int
    public let hitCount: Int
    public let missCount: Int
    public let hitRate: Double

    public init(
        totalItems: Int,
        expiredItems: Int,
        validItems: Int,
        hitCount: Int = 0,
        missCount: Int = 0,
        hitRate: Double = 0
    ) {
        self.totalItems = totalItems
        self.expiredItems = expiredItems
        self.validItems = validItems
        self.hitCount = hitCount
        self.missCount = missCount
        self.hitRate = hitRate
    }
}