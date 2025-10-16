//
//  CharacterRepositoryProtocol.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

public protocol CharacterRepositoryProtocol {
    func fetchCharacters(page: Int) -> AnyPublisher<[CharacterEntity], DomainError>
    func fetchCharacter(by id: Int) -> AnyPublisher<CharacterEntity, DomainError>
    func searchCharacters(name: String, status: CharacterStatus?, species: String?, gender: CharacterGender?, page: Int) -> AnyPublisher<[CharacterEntity], DomainError>
    func getFavoriteCharacters() -> AnyPublisher<[CharacterEntity], DomainError>
    func toggleFavorite(characterId: Int) -> AnyPublisher<Bool, DomainError>
    func isFavorite(characterId: Int) -> AnyPublisher<Bool, DomainError>
}