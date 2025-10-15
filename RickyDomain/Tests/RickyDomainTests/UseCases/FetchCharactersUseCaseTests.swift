//
//  FetchCharactersUseCaseTests.swift
//  RickyDomainTests
//
//  Created by Burak Arslan on 14.10.2025.
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
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    func testExecute_Success() {
        // Given
        let expectedCharacters = [
            createMockCharacterEntity(id: 1, name: "Rick"),
            createMockCharacterEntity(id: 2, name: "Morty")
        ]
        mockRepository.charactersToReturn = expectedCharacters

        let expectation = XCTestExpectation(description: "Fetch characters")

        // When
        let parameters = FetchCharactersParameters(page: 1, refresh: false)
        sut.execute(parameters: parameters)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        XCTFail("Expected success")
                    }
                },
                receiveValue: { characters in
                    // Then
                    XCTAssertEqual(characters.count, 2)
                    XCTAssertEqual(characters[0].name, "Rick")
                    XCTAssertEqual(characters[1].name, "Morty")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testExecute_Failure() {
        // Given
        mockRepository.shouldFail = true

        let expectation = XCTestExpectation(description: "Fetch characters failure")

        // When
        let parameters = FetchCharactersParameters(page: 1, refresh: false)
        sut.execute(parameters: parameters)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual(error, .networkUnavailable)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Expected failure")
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helper Methods

    private func createMockCharacterEntity(id: Int, name: String) -> CharacterEntity {
        CharacterEntity(
            id: id,
            name: name,
            status: .alive,
            species: "Human",
            type: "",
            gender: .male,
            origin: LocationEntity(name: "Earth", url: nil),
            location: LocationEntity(name: "Earth", url: nil),
            imageURL: nil,
            episodeURLs: [],
            profileURL: nil,
            createdDate: Date(),
            isFavorite: false
        )
    }
}

// MARK: - Mock Repository

class MockCharacterRepository: CharacterRepositoryProtocol {
    var charactersToReturn: [CharacterEntity] = []
    var shouldFail = false

    func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        if shouldFail {
            return Fail(error: .networkUnavailable)
                .eraseToAnyPublisher()
        }

        return Just(charactersToReturn)
            .setFailureType(to: DomainError.self)
            .eraseToAnyPublisher()
    }

    func fetchCharacter(by id: Int) -> AnyPublisher<CharacterEntity, DomainError> {
        Fail(error: .notFound).eraseToAnyPublisher()
    }

    func searchCharacters(
        name: String,
        status: CharacterStatus?,
        species: String?,
        gender: CharacterGender?,
        page: Int
    ) -> AnyPublisher<[CharacterEntity], DomainError> {
        Fail(error: .notFound).eraseToAnyPublisher()
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
