//
//  CharacterRepositoryTests.swift
//  RickyDataTests
//
//  Created by Burak Arslan on 14.10.2025.
//

import XCTest
import Combine
@testable import RickyData
@testable import RickyDomain
@testable import RickyModel
@testable import RickyNetworkInterface
@testable import RickyPersistance
@testable import RickyConfiguration

final class CharacterRepositoryTests: XCTestCase {
    var sut: CharacterRepository!
    var mockNetworkClient: MockNetworkClient!
    var mockFavoritesRepository: FavoritesRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        mockFavoritesRepository = FavoritesRepository()
        sut = CharacterRepository(
            networkClient: mockNetworkClient,
            favoritesRepository: mockFavoritesRepository
        )
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockNetworkClient = nil
        mockFavoritesRepository = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Fetch Characters Tests

    func testFetchCharacters_Success() {
        // Given
        let expectedCharacters = [
            createMockCharacter(id: 1, name: "Rick Sanchez"),
            createMockCharacter(id: 2, name: "Morty Smith")
        ]
        let response = PagedResponse(
            info: Info(count: 2, pages: 1, next: nil, prev: nil),
            results: expectedCharacters
        )
        mockNetworkClient.mockResponse = response

        let expectation = XCTestExpectation(description: "Fetch characters")

        // When
        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success, got failure")
                    }
                },
                receiveValue: { entities in
                    // Then
                    XCTAssertEqual(entities.count, 2)
                    XCTAssertEqual(entities[0].name, "Rick Sanchez")
                    XCTAssertEqual(entities[1].name, "Morty Smith")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchCharacters_NetworkError() {
        // Given
        mockNetworkClient.shouldFail = true

        let expectation = XCTestExpectation(description: "Network error")

        // When
        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertNotNil(error)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure, got success")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helper Methods

    private func createMockCharacter(id: Int, name: String) -> Character {
        Character(
            id: id,
            name: name,
            status: "Alive",
            species: "Human",
            type: "",
            gender: "Male",
            origin: Origin(name: "Earth", url: ""),
            location: Location(name: "Earth", url: ""),
            image: "https://example.com/image.png",
            episode: [],
            url: "",
            created: "2017-11-04T18:48:46.250Z"
        )
    }
}

// MARK: - Mock Network Client

class MockNetworkClient: NetworkClientProtocol {
    var mockResponse: Any?
    var shouldFail = false

    func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        if shouldFail {
            return Fail(error: NetworkError.requestFailed(500))
                .eraseToAnyPublisher()
        }

        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        return Fail(error: NetworkError.decodingFailed)
            .eraseToAnyPublisher()
    }
}
