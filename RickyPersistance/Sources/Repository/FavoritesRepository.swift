//
//  FavoritesRepository.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import Combine
import RickyModel

public final class FavoritesRepository: ObservableObject {
    @Published public private(set) var favorites: [Character] = []
    
    private let diskCache = DiskCache<[Character]>(folderName: "Favorites")
    private let fileName = "favorites.json"
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        loadFavorites()
    }
    
    public func toggleFavorite(_ character: Character) {
        if let index = favorites.firstIndex(where: { $0.id == character.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(character)
        }
        saveFavorites()
    }
    
    public func isFavorite(_ character: Character) -> Bool {
        favorites.contains { $0.id == character.id }
    }
    
    private func saveFavorites() {
        do {
            try diskCache.save(favorites, as: fileName)
        } catch {
            print("💾 Save error:", error)
        }
    }
    
    private func loadFavorites() {
        do {
            favorites = try diskCache.load(from: fileName)
        } catch {
            favorites = []
        }
    }
}