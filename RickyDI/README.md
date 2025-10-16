# RickyDI

**Dependency Injection Container** using the Factory pattern for centralized dependency management.

## Overview

RickyDI provides a type-safe, lazy-loading dependency injection container that manages the entire object graph of the application.

### Features
- ✅ Factory Pattern for lazy initialization
- ✅ Type-safe dependency resolution
- ✅ Singleton and transient scopes
- ✅ Circular dependency prevention
- ✅ Easy testing with mock injection

## Structure

```
RickyDI/
├── Sources/
│   ├── Container/
│   │   └── ServiceContainer.swift
│   ├── Factory/
│   │   └── Factory.swift
│   └── Extensions/
│       └── Resolver+Extensions.swift
└── Package.swift
```

## ServiceContainer

### Implementation

```swift
public final class ServiceContainer {
    public static let shared = ServiceContainer()

    private init() {}

    // MARK: - Network
    public lazy var networkClient: Factory<NetworkClient> = {
        Factory {
            NetworkClient(configuration: self.configuration.resolve())
        }
    }()

    // MARK: - Repositories
    public lazy var characterRepository: Factory<CharacterRepository> = {
        Factory {
            CharacterRepository(
                networkClient: self.networkClient.resolve(),
                configuration: self.configuration.resolve()
            )
        }
    }()

    // MARK: - Use Cases
    public lazy var fetchCharactersUseCase: Factory<FetchCharactersUseCase> = {
        Factory {
            FetchCharactersUseCase(
                characterRepository: self.characterRepository.resolve()
            )
        }
    }()
}
```

### Usage

```swift
// In ViewModel
final class CharacterListViewModel {
    private let fetchCharactersUseCase: FetchCharactersUseCase

    init(
        fetchCharactersUseCase: FetchCharactersUseCase = ServiceContainer.shared.fetchCharactersUseCase.resolve()
    ) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
    }
}
```

## Factory Pattern

```swift
public final class Factory<T> {
    private let builder: () -> T
    private var instance: T?

    public init(builder: @escaping () -> T) {
        self.builder = builder
    }

    public func resolve() -> T {
        if let instance = instance {
            return instance
        }
        let newInstance = builder()
        instance = newInstance
        return newInstance
    }

    public func reset() {
        instance = nil
    }
}
```

## Testing

```swift
// Mock injection for testing
final class MockServiceContainer: ServiceContainer {
    var mockCharacterRepository: MockCharacterRepository!

    override lazy var characterRepository: Factory<CharacterRepository> = {
        Factory { self.mockCharacterRepository }
    }()
}
```

## Dependencies

- **RickyDomain** - Use cases
- **RickyData** - Repositories
- **RickyNetwork** - Network client
- **RickyPersistance** - Cache
- **RickyConfiguration** - Config

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
