//
//  ToggleFavoriteUseCase.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

public struct ToggleFavoriteParameters {
    public let characterId: Int
    
    public init(characterId: Int) {
        self.characterId = characterId
    }
}

public final class ToggleFavoriteUseCase: UseCaseProtocol {
    public typealias Parameters = ToggleFavoriteParameters
    public typealias ReturnType = Bool
    public typealias ErrorType = DomainError
    
    private let characterRepository: CharacterRepositoryProtocol
    
    public init(characterRepository: CharacterRepositoryProtocol) {
        self.characterRepository = characterRepository
    }
    
    public func execute(parameters: ToggleFavoriteParameters) -> AnyPublisher<Bool, DomainError> {
        return characterRepository
            .toggleFavorite(characterId: parameters.characterId)
            .handleEvents(receiveSubscription: { _ in
                print("🎯 ToggleFavoriteUseCase: Toggling favorite for character \(parameters.characterId)")
            }, receiveOutput: { isFavorite in
                let action = isFavorite ? "added to" : "removed from"
                print("✅ ToggleFavoriteUseCase: Character \(parameters.characterId) \(action) favorites")
            }, receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("❌ ToggleFavoriteUseCase: Failed with error: \(error)")
                }
            })
            .eraseToAnyPublisher()
    }
}