//
//  MemoryCacheTests.swift
//  RickyPersistanceTests
//
//  Created by Burak Arslan on 14.10.2025.
//

import XCTest
@testable import RickyPersistance

final class MemoryCacheTests: XCTestCase {
    var sut: MemoryCache<String, String>!

    override func setUp() {
        super.setUp()
        sut = MemoryCache(policy: .short)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSetAndGet() {
        // Given
        let key = "test_key"
        let value = "test_value"

        // When
        sut.set(value, for: key)
        let retrieved = sut.get(for: key)

        // Then
        XCTAssertEqual(retrieved, value)
    }

    func testGet_NonExistentKey_ReturnsNil() {
        // When
        let retrieved = sut.get(for: "non_existent")

        // Then
        XCTAssertNil(retrieved)
    }

    func testRemove() {
        // Given
        let key = "test_key"
        let value = "test_value"
        sut.set(value, for: key)

        // When
        sut.remove(for: key)
        let retrieved = sut.get(for: key)

        // Then
        XCTAssertNil(retrieved)
    }

    func testClear() {
        // Given
        sut.set("value1", for: "key1")
        sut.set("value2", for: "key2")

        // When
        sut.clear()

        // Then
        XCTAssertNil(sut.get(for: "key1"))
        XCTAssertNil(sut.get(for: "key2"))
    }

    func testExpiration() {
        // Given
        let cache = MemoryCache<String, String>(
            policy: CachePolicy(ttl: 0.1) // 100ms
        )
        cache.set("value", for: "key")

        // When - wait for expiration
        let expectation = XCTestExpectation(description: "Wait for expiration")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        let retrieved = cache.get(for: "key")

        // Then
        XCTAssertNil(retrieved, "Cached value should have expired")
    }

    func testStatistics() {
        // Given
        sut.set("value1", for: "key1")
        sut.set("value2", for: "key2")

        // When
        let stats = sut.statistics

        // Then
        XCTAssertEqual(stats.totalItems, 2)
        XCTAssertEqual(stats.validItems, 2)
        XCTAssertEqual(stats.expiredItems, 0)
    }

    func testCleanupExpired() {
        // Given
        let cache = MemoryCache<String, String>(
            policy: CachePolicy(ttl: 0.1)
        )
        cache.set("value1", for: "key1")
        cache.set("value2", for: "key2", policy: .long)

        // Wait for first item to expire
        let expectation = XCTestExpectation(description: "Wait for expiration")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // When
        cache.cleanupExpired()

        // Then
        XCTAssertNil(cache.get(for: "key1"), "Expired item should be removed")
        XCTAssertNotNil(cache.get(for: "key2"), "Valid item should remain")
    }

    func testThreadSafety() {
        // Given
        let iterations = 1000
        let expectation = XCTestExpectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = iterations * 2

        // When - perform concurrent reads and writes
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            sut.set("value_\(index)", for: "key_\(index)")
            expectation.fulfill()
        }

        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            _ = sut.get(for: "key_\(index)")
            expectation.fulfill()
        }

        // Then - no crashes
        wait(for: [expectation], timeout: 5.0)
    }
}
