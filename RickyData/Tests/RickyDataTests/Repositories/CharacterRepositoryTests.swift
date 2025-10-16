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

    func testFetchCharacters_Success_ReturnsCharacters() {
        // Given
        let expectedCharacters = [
            createMockCharacter(id: 1, name: "Rick"),
            createMockCharacter(id: 2, name: "Morty")
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
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got failure: \(error)")
                    }
                },
                receiveValue: { entities in
                    // Then
                    XCTAssertEqual(entities.count, 2, "Should return 2 characters")
                    XCTAssertTrue(self.mockNetworkClient.requestWasMade, "Network request should be made")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchCharacters_NetworkError_ReturnsError() {
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
                        // Error should be mapped from NetworkError to DomainError
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

    func testFetchCharacters_CachesResults() {
        // Given
        let characters = [createMockCharacter(id: 1, name: "Rick")]
        let response = PagedResponse(
            info: Info(count: 1, pages: 1, next: nil, prev: nil),
            results: characters
        )
        mockNetworkClient.mockResponse = response

        let firstExpectation = XCTestExpectation(description: "First fetch")
        let secondExpectation = XCTestExpectation(description: "Second fetch")

        // When - First fetch
        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    firstExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [firstExpectation], timeout: 1.0)

        // Reset network mock
        mockNetworkClient.requestWasMade = false
        mockNetworkClient.mockResponse = nil

        // When - Second fetch (should use cache)
        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { entities in
                    // Then
                    XCTAssertEqual(entities.count, 1)
                    XCTAssertEqual(entities[0].name, "Rick")
                    XCTAssertFalse(self.mockNetworkClient.requestWasMade, "Network request should not be made for cached data")
                    secondExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [secondExpectation], timeout: 1.0)
    }

    // Note: Caching is controlled by AppConfiguration.shared which is read-only
    // We test caching behavior with default configuration (caching enabled)

    // MARK: - Request Deduplication Tests

    func testFetchCharacters_SimultaneousRequests_DeduplicatesRequests() {
        // Given
        let characters = [createMockCharacter(id: 1, name: "Rick")]
        let response = PagedResponse(
            info: Info(count: 1, pages: 1, next: nil, prev: nil),
            results: characters
        )
        mockNetworkClient.mockResponse = response
        mockNetworkClient.requestDelay = 0.2

        let firstExpectation = XCTestExpectation(description: "First request")
        let secondExpectation = XCTestExpectation(description: "Second request")

        // When - Make two simultaneous requests
        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in firstExpectation.fulfill() }
            )
            .store(in: &cancellables)

        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in secondExpectation.fulfill() }
            )
            .store(in: &cancellables)

        // Then
        wait(for: [firstExpectation, secondExpectation], timeout: 1.0)
        XCTAssertEqual(mockNetworkClient.requestCount, 1, "Should only make one network request for duplicate requests")
    }

    // MARK: - Fetch Character By ID Tests

    func testFetchCharacter_Success_ReturnsCharacter() {
        // Given
        let character = createMockCharacter(id: 1, name: "Rick Sanchez")
        mockNetworkClient.mockResponse = character

        let expectation = XCTestExpectation(description: "Fetch character by ID")

        // When
        sut.fetchCharacter(by: 1)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success, got failure")
                    }
                },
                receiveValue: { entity in
                    // Then
                    XCTAssertEqual(entity.id, 1)
                    XCTAssertEqual(entity.name, "Rick Sanchez")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchCharacter_NetworkError_ReturnsError() {
        // Given
        mockNetworkClient.shouldFail = true

        let expectation = XCTestExpectation(description: "Fetch character error")

        // When
        sut.fetchCharacter(by: 999)
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

    // MARK: - Search Characters Tests

    func testSearchCharacters_Success_ReturnsFilteredCharacters() {
        // Given
        let characters = [
            createMockCharacter(id: 1, name: "Rick Sanchez")
        ]
        let response = PagedResponse(
            info: Info(count: 1, pages: 1, next: nil, prev: nil),
            results: characters
        )
        mockNetworkClient.mockResponse = response

        let expectation = XCTestExpectation(description: "Search characters")

        // When
        sut.searchCharacters(name: "Rick", status: .alive, species: "Human", gender: .male, page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { entities in
                    // Then
                    XCTAssertEqual(entities.count, 1)
                    XCTAssertEqual(entities[0].name, "Rick Sanchez")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchCharacters_CachesResults() {
        // Given
        let characters = [createMockCharacter(id: 1, name: "Rick")]
        let response = PagedResponse(
            info: Info(count: 1, pages: 1, next: nil, prev: nil),
            results: characters
        )
        mockNetworkClient.mockResponse = response

        let firstExpectation = XCTestExpectation(description: "First search")
        let secondExpectation = XCTestExpectation(description: "Second search")

        // When - First search
        sut.searchCharacters(name: "Rick", status: nil, species: nil, gender: nil, page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in firstExpectation.fulfill() }
            )
            .store(in: &cancellables)

        wait(for: [firstExpectation], timeout: 1.0)

        mockNetworkClient.requestWasMade = false

        // When - Second search with same parameters
        sut.searchCharacters(name: "Rick", status: nil, species: nil, gender: nil, page: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { entities in
                    // Then
                    XCTAssertFalse(self.mockNetworkClient.requestWasMade, "Should use cached search results")
                    XCTAssertEqual(entities.count, 1)
                    secondExpectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [secondExpectation], timeout: 1.0)
    }

    // MARK: - Favorite Operations Tests

    func testGetFavoriteCharacters_ReturnsAllFavorites() {
        // Given
        let character1 = createMockCharacter(id: 1, name: "Rick")
        let character2 = createMockCharacter(id: 2, name: "Morty")
        mockFavoritesRepository.toggleFavorite(character1)
        mockFavoritesRepository.toggleFavorite(character2)

        let expectation = XCTestExpectation(description: "Get favorites")

        // When
        sut.getFavoriteCharacters()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { entities in
                    // Then
                    XCTAssertEqual(entities.count, 2)
                    XCTAssertTrue(entities.allSatisfy { $0.isFavorite })
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testToggleFavorite_RemovesExistingFavorite() {
        // Given
        let character = createMockCharacter(id: 1, name: "Rick")
        mockFavoritesRepository.toggleFavorite(character)
        XCTAssertEqual(mockFavoritesRepository.favorites.count, 1)

        let expectation = XCTestExpectation(description: "Toggle favorite")

        // When
        sut.toggleFavorite(characterId: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { isFavorite in
                    // Then
                    XCTAssertFalse(isFavorite)
                    XCTAssertEqual(self.mockFavoritesRepository.favorites.count, 0)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testToggleFavorite_AddsNewFavorite() {
        // Given
        let character = createMockCharacter(id: 1, name: "Rick")
        mockNetworkClient.mockResponse = character

        let expectation = XCTestExpectation(description: "Toggle favorite")

        // When
        sut.toggleFavorite(characterId: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { isFavorite in
                    // Then
                    XCTAssertTrue(isFavorite)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testIsFavorite_ReturnsTrueForFavoriteCharacter() {
        // Given
        let character = createMockCharacter(id: 1, name: "Rick")
        mockFavoritesRepository.toggleFavorite(character)

        let expectation = XCTestExpectation(description: "Check favorite")

        // When
        sut.isFavorite(characterId: 1)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { isFavorite in
                    // Then
                    XCTAssertTrue(isFavorite)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testIsFavorite_ReturnsFalseForNonFavoriteCharacter() {
        // Given - no favorites

        let expectation = XCTestExpectation(description: "Check non-favorite")

        // When
        sut.isFavorite(characterId: 999)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { isFavorite in
                    // Then
                    XCTAssertFalse(isFavorite)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Error Mapping Tests

    func testFetchCharacters_404Error_MapsToNotFoundError() {
        // Given
        mockNetworkClient.errorToReturn = .requestFailed(404)

        let expectation = XCTestExpectation(description: "Not found error")

        // When
        sut.fetchCharacters(page: 999)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual(error, .notFound)
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

    func testFetchCharacters_500Error_MapsToServerError() {
        // Given
        mockNetworkClient.errorToReturn = .requestFailed(500)

        let expectation = XCTestExpectation(description: "Server error")

        // When
        sut.fetchCharacters(page: 1)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then - 500 should be mapped to serverError
                        if case .serverError = error {
                            expectation.fulfill()
                        } else {
                            XCTFail("Expected serverError, got \(error)")
                        }
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
    var errorToReturn: NetworkError = .requestFailed(500)
    var requestWasMade = false
    var requestCount = 0
    var requestDelay: TimeInterval = 0

    func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        requestWasMade = true
        requestCount += 1

        let publisher: AnyPublisher<T, NetworkError>

        if shouldFail {
            publisher = Fail(error: errorToReturn)
                .eraseToAnyPublisher()
        } else if let response = mockResponse as? T {
            publisher = Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            publisher = Fail(error: .decodingFailed)
                .eraseToAnyPublisher()
        }

        if requestDelay > 0 {
            return publisher
                .delay(for: .seconds(requestDelay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        return publisher
    }
}
