//
//  FetchCharactersUseCase.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

public struct FetchCharactersParameters {
    public let page: Int
    public let refresh: Bool
    
    public init(page: Int = 1, refresh: Bool = false) {
        self.page = page
        self.refresh = refresh
    }
}

public final class FetchCharactersUseCase: UseCaseProtocol {
    public typealias Parameters = FetchCharactersParameters
    public typealias ReturnType = [CharacterEntity]
    public typealias ErrorType = DomainError
    
    private let characterRepository: CharacterRepositoryProtocol
    
    public init(characterRepository: CharacterRepositoryProtocol) {
        self.characterRepository = characterRepository
    }
    
    public func execute(parameters: FetchCharactersParameters) -> AnyPublisher<[CharacterEntity], DomainError> {
        return characterRepository
            .fetchCharacters(page: parameters.page)
            .handleEvents(receiveSubscription: { _ in
                // Log start of use case
                print("🎯 FetchCharactersUseCase: Starting to fetch characters for page \(parameters.page)")
            }, receiveOutput: { characters in
                // Log success
                print("✅ FetchCharactersUseCase: Successfully fetched \(characters.count) characters")
            }, receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    // Log error
                    print("❌ FetchCharactersUseCase: Failed with error: \(error)")
                }
            })
            .eraseToAnyPublisher()
    }
}