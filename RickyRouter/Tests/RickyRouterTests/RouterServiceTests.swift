//
//  RouterServiceTests.swift
//  RickyRouterTests
//
//  Created by Burak Arslan on 16.10.2025.
//

import XCTest
@testable import RickyRouter
@testable import RickyDomain

@MainActor
final class RouterServiceTests: XCTestCase {

    var sut: RouterService!

    override func setUp() {
        super.setUp()
        sut = RouterService.shared
        sut.clearHistory()

        // Reset route stack
        while !sut.routeStack.isEmpty {
            sut.goBack()
        }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Navigation Tests

    func testNavigate_AddsRouteToStack() {
        // Given
        let character = createMockCharacter()
        let route = Route.characterDetail(character)

        // When
        sut.navigate(to: route)

        // Then
        XCTAssertEqual(sut.routeStack.count, 1)
        XCTAssertEqual(sut.routeStack.first, route)
        XCTAssertEqual(sut.navigationDepth, 1)
    }

    func testNavigate_AddsMultipleRoutes() {
        // Given
        let character = createMockCharacter()
        let route1 = Route.characterDetail(character)
        let route2 = Route.locationList

        // When
        sut.navigate(to: route1)
        sut.navigate(to: route2)

        // Then
        XCTAssertEqual(sut.routeStack.count, 2)
        XCTAssertEqual(sut.routeStack[0], route1)
        XCTAssertEqual(sut.routeStack[1], route2)
    }

    // MARK: - Go Back Tests

    func testGoBack_RemovesLastRoute() {
        // Given
        let character = createMockCharacter()
        sut.navigate(to: .characterDetail(character))
        sut.navigate(to: .locationList)

        // When
        sut.goBack()

        // Then
        XCTAssertEqual(sut.routeStack.count, 1)
        XCTAssertEqual(sut.routeStack.first, .characterDetail(character))
    }

    func testGoBack_EmptyStack_DoesNothing() {
        // Given - empty stack

        // When
        sut.goBack()

        // Then
        XCTAssertEqual(sut.routeStack.count, 0)
    }

    // MARK: - Pop To Root Tests

    func testPopToRoot_ClearsAllRoutes() {
        // Given
        let character = createMockCharacter()
        sut.navigate(to: .characterDetail(character))
        sut.navigate(to: .locationList)
        sut.navigate(to: .characterDetail(character))

        // When
        sut.popToRoot()

        // Then
        XCTAssertEqual(sut.routeStack.count, 0)
    }

    // MARK: - Replace Tests

    func testReplace_ReplacesCurrentRoute() {
        // Given
        let character = createMockCharacter()
        sut.navigate(to: .characterDetail(character))
        sut.navigate(to: .locationList)

        // When
        let newCharacter = createMockCharacter(id: 2)
        sut.replace(with: .characterDetail(newCharacter))

        // Then
        XCTAssertEqual(sut.routeStack.count, 2)
        XCTAssertEqual(sut.routeStack.last, .characterDetail(newCharacter))
    }

    // MARK: - Deep Navigation Tests

    func testNavigateDeep_AddsMultipleRoutes() {
        // Given
        let character = createMockCharacter()
        let routes: [Route] = [
            .characterDetail(character),
            .locationList
        ]

        // When
        sut.navigateDeep(to: routes)

        // Then
        XCTAssertEqual(sut.routeStack.count, 2)
        XCTAssertEqual(sut.routeStack[0], routes[0])
        XCTAssertEqual(sut.routeStack[1], routes[1])
    }

    // MARK: - Current Route Tests

    func testCurrentRoute_ReturnsLastRoute() {
        // Given
        let character = createMockCharacter()
        sut.navigate(to: .characterDetail(character))
        let expectedRoute = Route.locationList
        sut.navigate(to: expectedRoute)

        // When
        let currentRoute = sut.currentRoute

        // Then
        XCTAssertEqual(currentRoute, expectedRoute)
    }

    func testCurrentRoute_EmptyStack_ReturnsNil() {
        // Given - empty stack

        // When
        let currentRoute = sut.currentRoute

        // Then
        XCTAssertNil(currentRoute)
    }

    // MARK: - Is Current Route Tests

    func testIsCurrentRoute_WithMatchingRoute_ReturnsTrue() {
        // Given
        let route = Route.locationList
        sut.navigate(to: route)

        // When
        let isCurrent = sut.isCurrentRoute(route)

        // Then
        XCTAssertTrue(isCurrent)
    }

    func testIsCurrentRoute_WithDifferentRoute_ReturnsFalse() {
        // Given
        sut.navigate(to: .locationList)

        // When
        let character = createMockCharacter()
        let isCurrent = sut.isCurrentRoute(.characterDetail(character))

        // Then
        XCTAssertFalse(isCurrent)
    }

    // MARK: - Can Go Back Tests

    func testCanGoBack_WithRoutes_ReturnsTrue() {
        // Given
        sut.navigate(to: .locationList)

        // When
        let canGoBack = sut.canGoBack

        // Then
        XCTAssertTrue(canGoBack)
    }

    func testCanGoBack_EmptyStack_ReturnsFalse() {
        // Given - empty stack

        // When
        let canGoBack = sut.canGoBack

        // Then
        XCTAssertFalse(canGoBack)
    }

    // MARK: - Navigation History Tests

    func testGetHistory_ReturnsAllNavigatedRoutes() {
        // Given
        let character = createMockCharacter()
        let route1 = Route.characterDetail(character)
        let route2 = Route.locationList

        sut.navigate(to: route1)
        sut.navigate(to: route2)

        // When
        let history = sut.getHistory()

        // Then
        XCTAssertEqual(history.count, 2)
        XCTAssertEqual(history[0], route1)
        XCTAssertEqual(history[1], route2)
    }

    func testClearHistory_RemovesAllHistory() {
        // Given
        sut.navigate(to: .locationList)
        sut.navigate(to: .locationList)

        // When
        sut.clearHistory()

        // Then
        XCTAssertEqual(sut.getHistory().count, 0)
    }

    func testNavigationHistory_KeepsMaxSize() {
        // Given - Navigate more than maxHistorySize (50)
        for i in 0..<60 {
            let character = createMockCharacter(id: i)
            sut.navigate(to: .characterDetail(character))
        }

        // When
        let history = sut.getHistory()

        // Then
        XCTAssertEqual(history.count, 50, "History should not exceed max size")
    }

    // MARK: - Navigation Depth Tests

    func testNavigationDepth_ReturnsCorrectCount() {
        // Given
        sut.navigate(to: .locationList)
        sut.navigate(to: .locationList)
        sut.navigate(to: .locationList)

        // When
        let depth = sut.navigationDepth

        // Then
        XCTAssertEqual(depth, 3)
    }

    // MARK: - Helper Methods

    private func createMockCharacter(id: Int = 1) -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: "Test Character \(id)",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: LocationEntity(name: "Earth", url: nil),
            location: LocationEntity(name: "Earth", url: nil),
            imageURL: URL(string: "https://example.com/image.jpg"),
            episodeURLs: [],
            profileURL: URL(string: "https://example.com/character/\(id)"),
            createdDate: Date(),
            isFavorite: false
        )
    }
}
