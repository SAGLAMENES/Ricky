# Contributing to Ricky iOS

First off, thank you for considering contributing to Ricky! It's people like you that make Ricky such a great tool.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Architecture Guidelines](#architecture-guidelines)
5. [Coding Standards](#coding-standards)
6. [Testing Guidelines](#testing-guidelines)
7. [Pull Request Process](#pull-request-process)
8. [Documentation](#documentation)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all. Please be respectful and constructive in your interactions.

### Our Standards

**Examples of behavior that contributes to a positive environment:**

✅ Using welcoming and inclusive language
✅ Being respectful of differing viewpoints
✅ Gracefully accepting constructive criticism
✅ Focusing on what is best for the community
✅ Showing empathy towards other community members

**Examples of unacceptable behavior:**

❌ Trolling, insulting/derogatory comments, and personal attacks
❌ Public or private harassment
❌ Publishing others' private information without permission
❌ Other conduct which could reasonably be considered inappropriate

---

## Getting Started

### Prerequisites

- **Xcode 15.0+**
- **Swift 6.0+**
- **iOS 15.0+ SDK**
- **macOS 13.0+ (for development)**

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Navigate to https://github.com/Burak-Arslan/Ricky
   # Click "Fork" button
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/Ricky.git
   cd Ricky
   ```

3. **Open workspace**
   ```bash
   open Ricky.xcworkspace
   ```

4. **Build the project**
   - Press `⌘B` or select Product > Build
   - Ensure all packages compile without errors

5. **Run tests**
   - Press `⌘U` or select Product > Test
   - All tests should pass

### Project Structure

```
Ricky/
├── RickyApp/              # Main app target
├── RickyDomain/           # Business logic
├── RickyData/             # Data layer
├── RickyNetwork/          # Network layer
├── RickyPersistance/      # Caching layer
├── RickyConfiguration/    # App configuration
├── RickyDI/               # Dependency injection
├── RickyRouter/           # Navigation
├── RickyDesignSystem/     # UI components
├── RickyAppCore/          # Core utilities
├── RickyModel/            # Data models
├── RickyNetworkInterface/ # Network protocols
└── docs/                  # Documentation
```

---

## Development Workflow

### Branch Naming Convention

Use descriptive branch names following this pattern:

```
<type>/<short-description>

Examples:
feature/character-filters
bugfix/cache-expiration
refactor/repository-pattern
docs/api-documentation
test/use-case-coverage
```

**Types:**
- `feature/` - New features
- `bugfix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation changes
- `test/` - Test additions/improvements
- `chore/` - Maintenance tasks

### Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Example:**
```
feat(domain): add character filtering use case

- Add FilterCharactersUseCase with status/species filters
- Update CharacterRepositoryProtocol with filter parameters
- Add unit tests for filtering logic

Closes #123
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Test additions/modifications
- `chore:` - Build process or auxiliary tool changes

---

## Architecture Guidelines

Ricky follows **Clean Architecture** principles. Please ensure your contributions adhere to these guidelines:

### Layer Separation

```
Presentation → Domain ← Data → Infrastructure
```

### The Dependency Rule

**✅ ALLOWED:**
- Outer layers depend on inner layers
- Data layer implements Domain protocols
- ViewModels use Domain use cases

**❌ FORBIDDEN:**
- Inner layers depend on outer layers
- Domain depends on UI frameworks
- Circular dependencies

### Module Responsibilities

#### Domain Layer (Business Logic)
```swift
// ✅ DO: Pure Swift, no framework dependencies
public struct CharacterEntity {
    public let id: Int
    public let name: String

    public var isAlive: Bool {
        return status == "alive"
    }
}

// ❌ DON'T: Framework dependencies in Domain
import SwiftUI  // ❌ No UI imports in Domain
```

#### Data Layer (Data Management)
```swift
// ✅ DO: Implement domain protocols
public final class CharacterRepository: CharacterRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let cache: MemoryCache

    // Multi-tier caching implementation
}

// ❌ DON'T: Business logic in repositories
// Keep repositories focused on data operations
```

#### Presentation Layer (UI)
```swift
// ✅ DO: Use domain use cases
final class CharacterListViewModel {
    private let fetchCharactersUseCase: FetchCharactersUseCase

    func loadCharacters() {
        fetchCharactersUseCase.execute(parameters: params)
            .sink { ... }
    }
}

// ❌ DON'T: Direct network calls from ViewModel
// Always go through use cases
```

### Adding New Features

When adding a new feature, follow this order:

1. **Domain Layer First**
   ```swift
   // 1. Define entity
   public struct EpisodeEntity {
       public let id: Int
       public let name: String
   }

   // 2. Define repository protocol
   public protocol EpisodeRepositoryProtocol {
       func fetchEpisodes() -> AnyPublisher<[EpisodeEntity], DomainError>
   }

   // 3. Create use case
   public final class FetchEpisodesUseCase: UseCaseProtocol {
       private let repository: EpisodeRepositoryProtocol
       // ...
   }
   ```

2. **Data Layer Second**
   ```swift
   // 4. Create endpoint
   struct FetchEpisodesEndpoint: Endpoint { ... }

   // 5. Implement repository
   public final class EpisodeRepository: EpisodeRepositoryProtocol {
       // Implement with caching
   }

   // 6. Add mapper
   struct EpisodeMapper {
       static func toDomain(_ dto: Episode) -> EpisodeEntity
   }
   ```

3. **Presentation Layer Last**
   ```swift
   // 7. Create ViewModel
   final class EpisodeListViewModel {
       private let fetchEpisodesUseCase: FetchEpisodesUseCase
       // ...
   }

   // 8. Create View
   struct EpisodeListView: View {
       @StateObject var viewModel: EpisodeListViewModel
       // ...
   }
   ```

4. **Register in DI Container**
   ```swift
   // 9. Update ServiceContainer
   public lazy var episodeRepository: Factory<EpisodeRepository> = {
       Factory {
           EpisodeRepository(
               networkClient: self.networkClient.resolve()
           )
       }
   }()
   ```

---

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

#### Naming Conventions

```swift
// ✅ DO: Use descriptive names
func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError>

// ❌ DON'T: Use abbreviations
func fetchChars(p: Int) -> AnyPublisher<[CharEntity], Error>
```

#### Protocol Naming

```swift
// ✅ DO: End with "Protocol" for repositories
public protocol CharacterRepositoryProtocol { }

// ✅ DO: Or use "-able" suffix for capabilities
public protocol Cacheable { }

// ❌ DON'T: Generic names
public protocol Repository { }
```

#### Use Cases

```swift
// ✅ DO: Name as verb phrases
public final class FetchCharactersUseCase: UseCaseProtocol { }
public final class ToggleFavoriteUseCase: UseCaseProtocol { }

// ❌ DON'T: Noun-only names
public final class CharacterFetcher { }
```

### Code Organization

#### File Structure

```swift
// 1. Imports (standard library first, then frameworks, then custom)
import Foundation
import Combine
import RickyDomain

// 2. Type definition
public final class CharacterRepository {

    // 3. MARK: - Properties
    // Public properties first
    public var isLoading: Bool = false

    // Private properties after
    private let networkClient: NetworkClientProtocol

    // 4. MARK: - Initialization
    public init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    // 5. MARK: - Public Methods
    public func fetchCharacters() { }

    // 6. MARK: - Private Methods
    private func mapToEntities() { }
}
```

#### Access Control

```swift
// ✅ DO: Be explicit about access levels
public protocol CharacterRepositoryProtocol { }  // Public API
internal final class CacheManager { }            // Internal implementation
private var cache: [String: Any] = [:]           // Private details

// ❌ DON'T: Leave access level implicit for public APIs
protocol Repository { }  // Defaults to internal
```

### SwiftUI Best Practices

```swift
// ✅ DO: Extract subviews for clarity
struct CharacterListView: View {
    var body: some View {
        List {
            ForEach(characters) { character in
                CharacterRow(character: character)
            }
        }
    }
}

struct CharacterRow: View {
    let character: CharacterEntity

    var body: some View {
        HStack {
            // Row content
        }
    }
}

// ❌ DON'T: Put all view code in one body
// (Too complex, hard to maintain)
```

---

## Testing Guidelines

### Test Coverage Requirements

- **Domain Layer:** 90%+ coverage required
- **Data Layer:** 80%+ coverage required
- **Presentation Layer:** 70%+ coverage recommended

### Writing Tests

#### Unit Tests

```swift
import XCTest
@testable import RickyDomain

final class FetchCharactersUseCaseTests: XCTestCase {

    // MARK: - Properties
    var sut: FetchCharactersUseCase!
    var mockRepository: MockCharacterRepository!

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockRepository = MockCharacterRepository()
        sut = FetchCharactersUseCase(characterRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testFetchCharactersSuccess() {
        // Given
        let expectedCharacters = [mockCharacter]
        mockRepository.fetchCharactersResult = .success(expectedCharacters)

        // When
        var receivedCharacters: [CharacterEntity]?
        let expectation = self.expectation(description: "Fetch characters")

        sut.execute(parameters: params)
            .sink { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
                expectation.fulfill()
            } receiveValue: { characters in
                receivedCharacters = characters
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertEqual(receivedCharacters?.count, 1)
        XCTAssertEqual(receivedCharacters?.first?.id, mockCharacter.id)
    }

    func testFetchCharactersFailure() {
        // Given
        mockRepository.fetchCharactersResult = .failure(.networkError)

        // When
        var receivedError: DomainError?
        let expectation = self.expectation(description: "Fetch characters")

        sut.execute(parameters: params)
            .sink { completion in
                if case .failure(let error) = completion {
                    receivedError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail("Expected failure but got success")
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)

        // Then
        XCTAssertEqual(receivedError, .networkError)
    }
}
```

#### Mock Objects

```swift
final class MockCharacterRepository: CharacterRepositoryProtocol {
    var fetchCharactersResult: Result<[CharacterEntity], DomainError>?
    var fetchCharactersCallCount = 0

    func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError> {
        fetchCharactersCallCount += 1

        guard let result = fetchCharactersResult else {
            return Fail(error: DomainError.unknown).eraseToAnyPublisher()
        }

        switch result {
        case .success(let entities):
            return Just(entities)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
```

### Running Tests

```bash
# All tests
⌘U in Xcode

# Command line
xcodebuild test -workspace Ricky.xcworkspace \
    -scheme RickyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Specific package
swift test --package-path RickyDomain
swift test --package-path RickyData
```

---

## Pull Request Process

### Before Submitting

**Checklist:**
- [ ] Code follows the style guidelines
- [ ] All tests pass locally
- [ ] New tests added for new functionality
- [ ] Documentation updated (if needed)
- [ ] No compiler warnings
- [ ] Branch is up to date with `main`

### Pull Request Template

```markdown
## Description
Brief description of the changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Motivation and Context
Why is this change necessary? What problem does it solve?

## How Has This Been Tested?
- [ ] Unit tests
- [ ] Integration tests
- [ ] Manual testing

## Screenshots (if applicable)
Add screenshots to help explain your changes

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
- [ ] New and existing tests pass locally
```

### Review Process

1. **Automated Checks**
   - CI/CD pipeline runs tests
   - Code quality checks
   - Build verification

2. **Code Review**
   - At least one approval required
   - Address all review comments
   - Update PR based on feedback

3. **Merge**
   - Squash and merge preferred
   - Delete branch after merge
   - Celebrate! 🎉

---

## Documentation

### Code Documentation

Use Swift documentation comments:

```swift
/// Fetches characters from the Rick and Morty API with caching support.
///
/// This use case implements a multi-tier caching strategy:
/// - L1: Memory cache (nanoseconds)
/// - L2: Disk cache (milliseconds)
/// - L3: Network (seconds)
///
/// - Parameter parameters: Contains page number and refresh flag
/// - Returns: Publisher emitting character entities or domain error
/// - Note: Results are automatically cached with a 30-minute TTL
public final class FetchCharactersUseCase: UseCaseProtocol {

    /// Executes the use case to fetch characters
    /// - Parameter parameters: Fetch parameters (page, refresh)
    /// - Returns: Publisher with characters or error
    public func execute(parameters: FetchCharactersParameters)
        -> AnyPublisher<[CharacterEntity], DomainError> {
        // Implementation
    }
}
```

### README Updates

When adding new packages or features, update relevant READMEs:

- Main `README.md` - High-level overview
- Package READMEs - Module-specific details
- `docs/ARCHITECTURE.md` - Architecture changes

### API Documentation

Generate DocC documentation:

```bash
# Build documentation
xcodebuild docbuild -workspace Ricky.xcworkspace \
    -scheme RickyDomain \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Preview documentation
open ~/Library/Developer/Xcode/DerivedData/.../Build/Products/Debug-iphonesimulator/RickyDomain.doccarchive
```

---

## Questions?

If you have questions, please:

1. Check existing [documentation](docs/)
2. Search [existing issues](https://github.com/Burak-Arslan/Ricky/issues)
3. Open a new issue with the `question` label

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Ricky! 🙌

🤖 Generated with [Claude Code](https://claude.com/claude-code)
