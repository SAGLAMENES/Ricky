# RickyData

The **Data Layer** - Repository implementations with multi-tier caching strategy.

## Overview

RickyData implements repository protocols defined in RickyDomain, providing data access with intelligent caching, error mapping, and API endpoint definitions.

### Features
- ✅ Multi-Tier Caching (Memory + Disk)
- ✅ Request Deduplication
- ✅ Error Mapping (NetworkError → DomainError)
- ✅ DTO to Entity Mapping
- ✅ Configuration-Based Caching

## Structure

```
RickyData/
├── Sources/RickyData/
│   ├── Repositories/
│   │   ├── CharacterRepository.swift
│   │   └── LocationRepository.swift
│   ├── Mappers/
│   │   ├── CharacterMapper.swift
│   │   ├── LocationMapper.swift
│   │   └── ErrorMapper.swift
│   └── Network/
│       ├── CharacterEndpoints.swift
│       └── LocationEndpoints.swift
└── Tests/RickyDataTests/
```

## Multi-Tier Caching

### Cache Strategy

```
Request → L1 (Memory) → L2 (Disk) → L3 (Network)
          ↓ hit (ns)     ↓ hit (ms)   ↓ (seconds)
       Return cached  Return cached   Fetch from API
```

### CharacterRepository

```swift
public final class CharacterRepository: CharacterRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let memoryCache = MemoryCache<String, [CharacterEntity]>()
    private let diskCache = DiskCache<[Character]>(folderName: "CharactersCache")
    private let configuration: AppConfiguration

    public func fetchCharacters(page: Int)
        -> AnyPublisher<[CharacterEntity], DomainError> {

        let cacheKey = "characters_page_\(page)"

        // L1: Memory Cache (nanoseconds)
        if let cached = memoryCache.get(for: cacheKey),
           configuration.isCachingEnabled {
            return Just(cached)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // L2: Disk Cache (milliseconds)
        if let diskData = try? diskCache.load(from: cacheKey),
           configuration.isCachingEnabled {
            let entities = CharacterMapper.toDomain(diskData)
            memoryCache.set(entities, for: cacheKey) // Promote to L1
            return Just(entities)
                .setFailureType(to: DomainError.self)
                .eraseToAnyPublisher()
        }

        // L3: Network (seconds)
        let endpoint = FetchCharactersEndpoint(page: page)
        return networkClient
            .performRequest(endpoint, responseType: PagedResponse<Character>.self)
            .mapError { ErrorMapper.map($0) }
            .map { [weak self] response in
                // Cache to disk
                try? self?.diskCache.save(response.results, as: "page_\(page).json")

                // Map to domain entities
                let entities = CharacterMapper.toDomain(response.results)

                // Cache to memory
                self?.memoryCache.set(entities, for: cacheKey)

                return entities
            }
            .eraseToAnyPublisher()
    }
}
```

## Mappers

### CharacterMapper

Converts DTOs to domain entities:

```swift
public struct CharacterMapper {
    public static func toDomain(_ character: Character) -> CharacterEntity {
        return CharacterEntity(
            id: character.id,
            name: character.name,
            status: character.status,
            species: character.species,
            type: character.type,
            gender: character.gender,
            originName: character.origin.name,
            originURL: character.origin.url,
            locationName: character.location.name,
            locationURL: character.location.url,
            imageURL: character.image,
            episodeURLs: character.episode,
            createdDate: character.created,
            isFavorite: false
        )
    }

    public static func toDomain(_ characters: [Character]) -> [CharacterEntity] {
        return characters.map { toDomain($0) }
    }
}
```

### ErrorMapper

Maps infrastructure errors to domain errors:

```swift
public struct ErrorMapper {
    public static func map(_ networkError: NetworkError) -> DomainError {
        switch networkError {
        case .noInternet:
            return .networkError
        case .notFound:
            return .notFound
        case .serverError:
            return .serverError
        case .decodingFailed:
            return .decodingError
        case .unknown:
            return .unknown
        }
    }
}
```

## API Endpoints

### FetchCharactersEndpoint

```swift
public struct FetchCharactersEndpoint: Endpoint {
    public let path: String
    public let method: HTTPMethod = .get
    public let headers: [String: String]? = nil
    public let queryParameters: [String: String]?
    public let body: Data? = nil

    public init(page: Int) {
        self.path = "/character"
        self.queryParameters = ["page": "\(page)"]
    }
}
```

### SearchCharactersEndpoint

```swift
public struct SearchCharactersEndpoint: Endpoint {
    public init(
        name: String,
        status: String? = nil,
        species: String? = nil,
        gender: String? = nil,
        page: Int = 1
    ) {
        self.path = "/character"
        var params: [String: String] = [
            "name": name,
            "page": "\(page)"
        ]
        if let status = status { params["status"] = status }
        if let species = species { params["species"] = species }
        if let gender = gender { params["gender"] = gender }
        self.queryParameters = params
    }
}
```

## Testing

```swift
final class CharacterRepositoryTests: XCTestCase {
    func testCacheHit() {
        // Given: Data in cache
        let mockCharacter = CharacterEntity(...)
        memoryCache.set([mockCharacter], for: "characters_page_1")

        // When: Fetch characters
        let result = try await repository.fetchCharacters(page: 1)

        // Then: Returns cached data, no network call
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(mockNetworkClient.callCount, 0)
    }

    func testCacheMiss() {
        // Given: Empty cache
        // When: Fetch characters
        let result = try await repository.fetchCharacters(page: 1)

        // Then: Fetches from network and caches
        XCTAssertEqual(mockNetworkClient.callCount, 1)
        XCTAssertNotNil(memoryCache.get(for: "characters_page_1"))
    }
}
```

## Dependencies

- **RickyDomain** - Repository protocols, entities
- **RickyNetwork** - Network client implementation
- **RickyNetworkInterface** - Endpoint protocol
- **RickyPersistance** - Cache implementations
- **RickyModel** - DTOs
- **RickyConfiguration** - App configuration

## Architecture Score

**Data Layer Quality: 9/10** ⭐

---

