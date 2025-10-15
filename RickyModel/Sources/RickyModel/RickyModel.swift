// The Swift Programming Language
// https://docs.swift.org/swift-book

#if DEBUG
import Foundation

public extension CharacterResponse {
    static var sample: CharacterResponse {
        let json = """
        {
          "info": { "count": 826, "pages": 42, "next": null, "prev": null },
          "results": [
            {
              "id": 1,
              "name": "Rick Sanchez",
              "status": "Alive",
              "species": "Human",
              "type": "",
              "gender": "Male",
              "origin": { "name": "Earth", "url": "" },
              "location": { "name": "Citadel", "url": "" },
              "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
              "episode": [],
              "url": "",
              "created": "2023-01-01T00:00:00Z"
            }
          ]
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(CharacterResponse.self, from: json)
    }
}
#endif
