//
//  SearchCharactersUseCase.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

public struct SearchCharactersParameters {
    public let name: String
    public let status: CharacterStatus?
    public let species: String?
    public let gender: CharacterGender?
    public let page: Int
    
    public init(
        name: String,
        status: CharacterStatus? = nil,
        species: String? = nil,
        gender: CharacterGender? = nil,
        page: Int = 1
    ) {
        self.name = name
        self.status = status
        self.species = species
        self.gender = gender
        self.page = page
    }
}

public final class SearchCharactersUseCase: UseCaseProtocol {
    public typealias Parameters = SearchCharactersParameters
    public typealias ReturnType = [CharacterEntity]
    public typealias ErrorType = DomainError
    
    private let characterRepository: CharacterRepositoryProtocol
    
    public init(characterRepository: CharacterRepositoryProtocol) {
        self.characterRepository = characterRepository
    }
    
    public func execute(parameters: SearchCharactersParameters) -> AnyPublisher<[CharacterEntity], DomainError> {
        // Validate search parameters
        guard !parameters.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Fail(error: DomainError.validationError("Search name cannot be empty"))
                .eraseToAnyPublisher()
        }
        
        return characterRepository
            .searchCharacters(
                name: parameters.name,
                status: parameters.status,
                species: parameters.species,
                gender: parameters.gender,
                page: parameters.page
            )
            .handleEvents(receiveSubscription: { _ in
                print("🎯 SearchCharactersUseCase: Searching characters with name '\(parameters.name)'")
            }, receiveOutput: { characters in
                print("✅ SearchCharactersUseCase: Found \(characters.count) matching characters")
            }, receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("❌ SearchCharactersUseCase: Failed with error: \(error)")
                }
            })
            .eraseToAnyPublisher()
    }
}