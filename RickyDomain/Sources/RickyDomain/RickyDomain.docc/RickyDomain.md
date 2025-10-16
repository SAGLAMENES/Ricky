# ``RickyDomain``

Domain layer providing business logic, entities, and use cases for the Ricky app.

## Overview

RickyDomain is the core business logic layer in the Clean Architecture pattern. It contains:

- **Entities**: Domain models (CharacterEntity, LocationEntity)
- **Use Cases**: Business operations (FetchCharactersUseCase, SearchCharactersUseCase)
- **Repository Protocols**: Data layer contracts
- **Domain Errors**: Business-level error handling

This module has **zero dependencies** on other app modules, ensuring complete independence of business logic.

## Topics

### Entities

- ``CharacterEntity``
- ``LocationEntity``
- ``CharacterStatus``
- ``CharacterGender``

### Use Cases

- ``FetchCharactersUseCase``
- ``SearchCharactersUseCase``
- ``ToggleFavoriteUseCase``
- ``FetchLocationsUseCase``
- ``UseCaseProtocol``

### Repository Protocols

- ``CharacterRepositoryProtocol``
- ``LocationRepositoryProtocol``

### Errors

- ``DomainError``
- ``NetworkError``

### Parameters

- ``FetchCharactersParameters``
- ``SearchCharactersParameters``
- ``ToggleFavoriteParameters``
- ``FetchLocationsParameters``

## Clean Architecture

RickyDomain follows Clean Architecture principles:

```
┌─────────────────────────┐
│   Presentation Layer    │
│   (RickyApp)           │
└────────┬────────────────┘
         │ depends on
         ↓
┌─────────────────────────┐
│   Domain Layer          │
│   (RickyDomain)        │ ← No dependencies!
│   - Entities           │
│   - Use Cases          │
│   - Protocols          │
└────────┬────────────────┘
         ↑ implements
         │
┌─────────────────────────┐
│   Data Layer            │
│   (RickyData)          │
└─────────────────────────┘
```

## Use Case Pattern

Use cases encapsulate single business operations:

```swift
let useCase = FetchCharactersUseCase(
    characterRepository: repository
)

useCase.execute(parameters: FetchCharactersParameters(page: 1))
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { characters in
            // Update UI with characters
        }
    )
```

## Key Principles

### 1. Independence

Domain layer has no dependencies on:
- UI frameworks (UIKit, SwiftUI)
- Network libraries (URLSession)
- Persistence frameworks (CoreData, UserDefaults)
- Other app modules

### 2. Single Responsibility

Each use case has one clear purpose:
- `FetchCharactersUseCase` - Fetches paginated character list
- `SearchCharactersUseCase` - Searches characters with filters
- `ToggleFavoriteUseCase` - Toggles favorite status

### 3. Testability

Pure business logic is easily testable:

```swift
func testFetchCharacters_Success() {
    // Given
    let mockRepository = MockCharacterRepository()
    mockRepository.result = .success([character1, character2])
    let sut = FetchCharactersUseCase(characterRepository: mockRepository)

    // When
    let result = try await sut.execute(
        parameters: FetchCharactersParameters(page: 1)
    )

    // Then
    XCTAssertEqual(result.count, 2)
}
```

### 4. Reusability

Domain logic can be reused across:
- iOS app
- macOS app
- watchOS app
- Command-line tools
- Unit tests

## Entities

Domain entities represent business concepts:

### CharacterEntity

```swift
public struct CharacterEntity: Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let status: CharacterStatus
    public let species: String
    public let gender: CharacterGender
    public let origin: LocationEntity
    public let location: LocationEntity
    public let imageURL: URL?
    public var isFavorite: Bool
}
```

### LocationEntity

```swift
public struct LocationEntity: Identifiable, Hashable {
    public let id: Int?
    public let name: String
    public let type: String?
    public let dimension: String?
    public let residentURLs: [String]?
}
```

## Use Cases

All use cases conform to `UseCaseProtocol`:

```swift
public protocol UseCaseProtocol {
    associatedtype Parameters
    associatedtype ReturnType
    associatedtype ErrorType: Error

    func execute(parameters: Parameters)
        -> AnyPublisher<ReturnType, ErrorType>
}
```

### FetchCharactersUseCase

Fetches paginated character list:

```swift
let useCase = FetchCharactersUseCase(characterRepository: repository)
useCase.execute(parameters: FetchCharactersParameters(page: 1))
    .sink { characters in
        print("Fetched \(characters.count) characters")
    }
```

### SearchCharactersUseCase

Searches characters with filters:

```swift
let useCase = SearchCharactersUseCase(characterRepository: repository)
let parameters = SearchCharactersParameters(
    name: "Rick",
    status: .alive,
    species: "Human",
    gender: .male,
    page: 1
)
useCase.execute(parameters: parameters)
    .sink { characters in
        print("Found \(characters.count) matching characters")
    }
```

### ToggleFavoriteUseCase

Toggles favorite status:

```swift
let useCase = ToggleFavoriteUseCase(characterRepository: repository)
useCase.execute(parameters: ToggleFavoriteParameters(characterId: 1))
    .sink { isFavorite in
        print("Favorite: \(isFavorite)")
    }
```

## Repository Protocols

Define data layer contracts without implementation details:

```swift
public protocol CharacterRepositoryProtocol {
    func fetchCharacters(page: Int)
        -> AnyPublisher<[CharacterEntity], DomainError>

    func fetchCharacter(by id: Int)
        -> AnyPublisher<CharacterEntity, DomainError>

    func searchCharacters(
        name: String,
        status: CharacterStatus?,
        species: String?,
        gender: CharacterGender?,
        page: Int
    ) -> AnyPublisher<[CharacterEntity], DomainError>

    func getFavoriteCharacters()
        -> AnyPublisher<[CharacterEntity], DomainError>

    func toggleFavorite(characterId: Int)
        -> AnyPublisher<Bool, DomainError>
}
```

## Error Handling

Domain-level errors represent business failures:

```swift
public enum DomainError: Error, Equatable {
    case networkUnavailable
    case unauthorized
    case notFound
    case dataCorrupted
    case serverError(String)
    case validationError(String)
    case unknownError
}
```

Usage:

```swift
useCase.execute(parameters: params)
    .sink(
        receiveCompletion: { completion in
            if case .failure(let error) = completion {
                switch error {
                case .networkUnavailable:
                    showOfflineMessage()
                case .notFound:
                    showNotFoundError()
                case .serverError(let message):
                    showServerError(message)
                default:
                    showGenericError()
                }
            }
        },
        receiveValue: { result in
            // Handle success
        }
    )
```

## Dependency Injection

Use cases receive dependencies through constructor injection:

```swift
// In DI Container
let characterRepository = CharacterRepository(
    networkClient: networkClient,
    cache: cache
)

let fetchCharactersUseCase = FetchCharactersUseCase(
    characterRepository: characterRepository
)

// In ViewModel
class CharacterListViewModel: ObservableObject {
    private let fetchCharactersUseCase: FetchCharactersUseCase

    init(fetchCharactersUseCase: FetchCharactersUseCase) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
    }
}
```

## Testing

Domain layer is highly testable with mock repositories:

```swift
class MockCharacterRepository: CharacterRepositoryProtocol {
    var fetchCharactersResult: Result<[CharacterEntity], DomainError>

    func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        fetchCharactersResult.publisher.eraseToAnyPublisher()
    }
}

func testFetchCharacters_Success() {
    // Given
    let mockRepo = MockCharacterRepository()
    mockRepo.fetchCharactersResult = .success([character1, character2])
    let sut = FetchCharactersUseCase(characterRepository: mockRepo)

    // When
    let result = try await sut.execute(parameters: .init(page: 1))

    // Then
    XCTAssertEqual(result.count, 2)
}
```

## Best Practices

### 1. Keep Domain Pure

Domain layer should not depend on external frameworks:

```swift
// ✅ Good - Pure Swift types
public struct CharacterEntity {
    let name: String
    let status: CharacterStatus
}

// ❌ Bad - Framework dependency
import UIKit
public struct CharacterEntity {
    let image: UIImage
}
```

### 2. Use Case per Operation

Create focused use cases for each business operation:

```swift
// ✅ Good - Single responsibility
class FetchCharactersUseCase { }
class SearchCharactersUseCase { }

// ❌ Bad - Multiple responsibilities
class CharacterUseCase {
    func fetch() { }
    func search() { }
    func toggleFavorite() { }
}
```

### 3. Domain Errors

Use domain-specific errors, not network/persistence errors:

```swift
// ✅ Good - Domain error
enum DomainError {
    case networkUnavailable
    case unauthorized
}

// ❌ Bad - Framework error
enum DomainError {
    case urlSessionError(URLError)
    case coreDataError(NSError)
}
```

### 4. Immutable Entities

Prefer immutable value types:

```swift
// ✅ Good - Immutable struct
public struct CharacterEntity {
    public let id: Int
    public let name: String
}

// ❌ Bad - Mutable class
public class CharacterEntity {
    public var id: Int
    public var name: String
}
```

## See Also

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Use Case Pattern](https://en.wikipedia.org/wiki/Use_case)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
