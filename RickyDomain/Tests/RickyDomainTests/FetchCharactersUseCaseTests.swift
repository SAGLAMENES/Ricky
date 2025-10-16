//
//  FetchCharactersUseCaseTests.swift
//  RickyDomainTests
//
//  Created by Burak Arslan on 16.10.2025.
//

import XCTest
import Combine
@testable import RickyDomain

final class FetchCharactersUseCaseTests: XCTestCase {

    var sut: FetchCharactersUseCase!
    var mockRepository: MockCharacterRepository!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        sut = FetchCharactersUseCase(characterRepository: mockRepository)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testExecute_Success_ReturnsCharacters() {
        // Given
        let expectedCharacters = [
            createMockCharacter(id: 1),
            createMockCharacter(id: 2)
        ]
        mockRepository.fetchCharactersResult = .success(expectedCharacters)

        let expectation = expectation(description: "Fetch characters")
        var receivedCharacters: [CharacterEntity]?

        // When
        sut.execute(parameters: FetchCharactersParameters(page: 1))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { characters in
                    receivedCharacters = characters
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedCharacters?.count, 2)
        XCTAssertEqual(receivedCharacters?.first?.id, 1)
        XCTAssertTrue(mockRepository.fetchCharactersWasCalled)
    }

    func testExecute_CallsRepositoryWithCorrectPage() {
        // Given
        mockRepository.fetchCharactersResult = .success([])
        let expectedPage = 5

        let expectation = expectation(description: "Fetch characters")

        // When
        sut.execute(parameters: FetchCharactersParameters(page: expectedPage))
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(mockRepository.lastFetchedPage, expectedPage)
    }

    // MARK: - Failure Tests

    func testExecute_NetworkError_ReturnsError() {
        // Given
        mockRepository.fetchCharactersResult = .failure(.network(.noInternet))

        let expectation = expectation(description: "Network error")
        var receivedError: DomainError?

        // When
        sut.execute(parameters: FetchCharactersParameters(page: 1))
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertNotNil(receivedError)
        if case .network = receivedError {
            // Success
        } else {
            XCTFail("Expected network error")
        }
    }

    func testExecute_NotFoundError_ReturnsError() {
        // Given
        mockRepository.fetchCharactersResult = .failure(.notFound)

        let expectation = expectation(description: "Not found error")
        var receivedError: DomainError?

        // When
        sut.execute(parameters: FetchCharactersParameters(page: 999))
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedError, .notFound)
    }

    // MARK: - Edge Cases

    func testExecute_EmptyResult_ReturnsEmptyArray() {
        // Given
        mockRepository.fetchCharactersResult = .success([])

        let expectation = expectation(description: "Empty result")
        var receivedCharacters: [CharacterEntity]?

        // When
        sut.execute(parameters: FetchCharactersParameters(page: 1))
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { characters in
                    receivedCharacters = characters
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedCharacters?.count, 0)
    }

    // MARK: - Helper Methods

    private func createMockCharacter(id: Int) -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: "Character \(id)",
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: LocationEntity(name: "Earth", url: nil),
            location: LocationEntity(name: "Earth", url: nil),
            imageURL: URL(string: "https://example.com/\(id).jpg"),
            episodeURLs: [],
            profileURL: URL(string: "https://example.com/\(id)"),
            createdDate: Date(),
            isFavorite: false
        )
    }
}

// MARK: - Mock Repository

class MockCharacterRepository: CharacterRepositoryProtocol {
    var fetchCharactersResult: Result<[CharacterEntity], DomainError> = .success([])
    var fetchCharactersWasCalled = false
    var lastFetchedPage: Int?

    func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        fetchCharactersWasCalled = true
        lastFetchedPage = page
        return fetchCharactersResult.publisher.eraseToAnyPublisher()
    }

    func fetchCharacter(by id: Int) -> AnyPublisher<CharacterEntity, DomainError> {
        Fail(error: DomainError.notFound).eraseToAnyPublisher()
    }

    func searchCharacters(name: String, status: CharacterStatus?, species: String?, gender: CharacterGender?, page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        Just([]).setFailureType(to: DomainError.self).eraseToAnyPublisher()
    }

    func getFavoriteCharacters() -> AnyPublisher<[CharacterEntity], DomainError> {
        Just([]).setFailureType(to: DomainError.self).eraseToAnyPublisher()
    }

    func toggleFavorite(characterId: Int) -> AnyPublisher<Bool, DomainError> {
        Just(true).setFailureType(to: DomainError.self).eraseToAnyPublisher()
    }

    func isFavorite(characterId: Int) -> AnyPublisher<Bool, DomainError> {
        Just(false).setFailureType(to: DomainError.self).eraseToAnyPublisher()
    }
}
