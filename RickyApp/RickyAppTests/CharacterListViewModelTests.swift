//
//  CharacterListViewModelTests.swift
//  RickyAppTests
//
//  Created by Burak Arslan on 16.10.2025.
//

import XCTest
import Combine
@testable import RickyApp
@testable import RickyDomain

@MainActor
final class CharacterListViewModelTests: XCTestCase {

    var sut: CharacterListViewModel!
    var mockFetchUseCase: MockFetchCharactersUseCase!
    var mockSearchUseCase: MockSearchCharactersUseCase!
    var mockToggleFavoriteUseCase: MockToggleFavoriteUseCase!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockFetchUseCase = MockFetchCharactersUseCase()
        mockSearchUseCase = MockSearchCharactersUseCase()
        mockToggleFavoriteUseCase = MockToggleFavoriteUseCase()
        cancellables = Set<AnyCancellable>()

        sut = CharacterListViewModel(
            fetchCharactersUseCase: mockFetchUseCase,
            searchCharactersUseCase: mockSearchUseCase,
            toggleFavoriteUseCase: mockToggleFavoriteUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockFetchUseCase = nil
        mockSearchUseCase = nil
        mockToggleFavoriteUseCase = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Fetch Characters Tests

    func testFetchCharacters_Success_UpdatesCharacters() async {
        // Given
        let expectedCharacters = [createMockCharacter(id: 1), createMockCharacter(id: 2)]
        mockFetchUseCase.result = .success(expectedCharacters)

        // When
        sut.fetchCharacters()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second

        // Then
        XCTAssertEqual(sut.characters.count, 2)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testFetchCharacters_Failure_SetsErrorMessage() async {
        // Given
        mockFetchUseCase.result = .failure(.network(.noInternet))

        // When
        sut.fetchCharacters()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(sut.characters.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testFetchCharacters_SetsLoadingState() {
        // Given
        mockFetchUseCase.delay = 0.5

        // When
        sut.fetchCharacters()

        // Then - immediately after call
        XCTAssertTrue(sut.isLoading)
    }

    func testFetchCharacters_Refresh_ClearsExistingData() async {
        // Given
        sut.characters = [createMockCharacter(id: 1)]
        sut.currentPage = 3
        mockFetchUseCase.result = .success([createMockCharacter(id: 2)])

        // When
        sut.fetchCharacters(refresh: true)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertEqual(sut.characters.count, 1)
        XCTAssertEqual(sut.characters.first?.id, 2)
    }

    // MARK: - Load More Tests

    func testLoadMore_AppendsCharacters() async {
        // Given
        sut.characters = [createMockCharacter(id: 1)]
        sut.currentPage = 1
        mockFetchUseCase.result = .success([createMockCharacter(id: 2)])

        // When
        sut.loadMore()

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.characters.count, 2)
    }

    func testLoadMore_WhenLoading_DoesNothing() {
        // Given
        sut.isLoading = true
        let initialPage = sut.currentPage

        // When
        sut.loadMore()

        // Then
        XCTAssertEqual(sut.currentPage, initialPage)
    }

    // MARK: - Search Tests

    func testSearch_UpdatesSearchQuery() {
        // Given
        let searchText = "Rick"

        // When
        sut.searchQuery = searchText

        // Then
        XCTAssertEqual(sut.searchQuery, searchText)
    }

    func testSearch_EmptyQuery_FetchesAllCharacters() async {
        // Given
        mockFetchUseCase.result = .success([createMockCharacter(id: 1)])
        sut.searchQuery = "Rick"

        // When
        sut.searchQuery = ""

        try? await Task.sleep(nanoseconds: 600_000_000) // Wait for debounce

        // Then
        XCTAssertTrue(mockFetchUseCase.executeWasCalled)
    }

    // MARK: - Toggle Favorite Tests

    func testToggleFavorite_UpdatesCharacterInList() async {
        // Given
        let character = createMockCharacter(id: 1, isFavorite: false)
        sut.characters = [character]
        mockToggleFavoriteUseCase.result = .success(true)

        // When
        sut.toggleFavorite(characterId: 1)

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(mockToggleFavoriteUseCase.executeWasCalled)
    }

    func testToggleFavorite_OptimisticUpdate() {
        // Given
        let character = createMockCharacter(id: 1, isFavorite: false)
        sut.characters = [character]
        mockToggleFavoriteUseCase.result = .success(true)

        // When
        sut.toggleFavorite(characterId: 1)

        // Then - immediate optimistic update
        XCTAssertTrue(sut.characters[0].isFavorite)
    }

    // MARK: - Refresh Tests

    func testRefresh_ResetsPageAndFetches() async {
        // Given
        sut.currentPage = 5
        mockFetchUseCase.result = .success([createMockCharacter(id: 1)])

        // When
        sut.refresh()

        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(sut.currentPage, 1)
        XCTAssertTrue(mockFetchUseCase.executeWasCalled)
    }

    // MARK: - Helper Methods

    private func createMockCharacter(id: Int, isFavorite: Bool = false) -> CharacterEntity {
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
            isFavorite: isFavorite
        )
    }
}

// MARK: - Mock Use Cases

class MockFetchCharactersUseCase: FetchCharactersUseCase {
    var result: Result<[CharacterEntity], DomainError> = .success([])
    var executeWasCalled = false
    var delay: TimeInterval = 0

    init() {
        super.init(characterRepository: MockCharacterRepository())
    }

    override func execute(parameters: FetchCharactersParameters) -> AnyPublisher<[CharacterEntity], DomainError> {
        executeWasCalled = true

        if delay > 0 {
            return Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                    promise(self.result)
                }
            }.eraseToAnyPublisher()
        }

        return result.publisher.eraseToAnyPublisher()
    }
}

class MockSearchCharactersUseCase: SearchCharactersUseCase {
    var result: Result<[CharacterEntity], DomainError> = .success([])
    var executeWasCalled = false

    init() {
        super.init(characterRepository: MockCharacterRepository())
    }

    override func execute(parameters: SearchCharactersParameters) -> AnyPublisher<[CharacterEntity], DomainError> {
        executeWasCalled = true
        return result.publisher.eraseToAnyPublisher()
    }
}

class MockToggleFavoriteUseCase: ToggleFavoriteUseCase {
    var result: Result<Bool, DomainError> = .success(true)
    var executeWasCalled = false

    init() {
        super.init(characterRepository: MockCharacterRepository())
    }

    override func execute(parameters: ToggleFavoriteParameters) -> AnyPublisher<Bool, DomainError> {
        executeWasCalled = true
        return result.publisher.eraseToAnyPublisher()
    }
}

class MockCharacterRepository: CharacterRepositoryProtocol {
    func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        Just([]).setFailureType(to: DomainError.self).eraseToAnyPublisher()
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
