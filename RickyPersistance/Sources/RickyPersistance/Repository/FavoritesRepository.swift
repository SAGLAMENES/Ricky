//
//  FavoritesRepository.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine
import CoreData
import RickyModel

/// Repository for managing favorite characters using CoreData
public final class FavoritesRepository: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var favorites: [Character] = []
    
    // MARK: - Private Properties
    
    private let coreDataStack: CoreDataStack
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        loadFavorites()
        setupNotifications()
    }
    
    // MARK: - Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: coreDataStack.viewContext
        )
    }
    
    @objc private func contextDidSave(_ notification: Notification) {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Toggle favorite status for a character
    public func toggleFavorite(_ character: Character) {
        let context = coreDataStack.viewContext
        
        if isFavorite(character) {
            removeFavorite(character, in: context)
        } else {
            addFavorite(character, in: context)
        }
        
        coreDataStack.saveContext()
        loadFavorites()
    }
    
    /// Check if character is in favorites
    public func isFavorite(_ character: Character) -> Bool {
        return isFavorite(characterId: character.id)
    }
    
    /// Check if character ID is in favorites
    public func isFavorite(characterId: Int) -> Bool {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<FavoriteCharacterEntity> = FavoriteCharacterEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", Int64(characterId))
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
    /// Get all favorite character IDs
    public func getFavoriteIds() -> Set<Int> {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<FavoriteCharacterEntity> = FavoriteCharacterEntity.fetchRequest()
        fetchRequest.propertiesToFetch = ["id"]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return Set(entities.map { Int($0.id) })
        } catch {
            return []
        }
    }
    
    /// Delete all favorites (for testing)
    public func deleteAllFavorites() {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteCharacterEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            
            coreDataStack.saveContext()
            loadFavorites()
        } catch {
        }
    }
    
    // MARK: - Private Methods
    
    private func addFavorite(_ character: Character, in context: NSManagedObjectContext) {
        let entity = FavoriteCharacterEntity(context: context)
        entity.id = Int64(character.id)
        entity.name = character.name
        entity.status = character.status
        entity.species = character.species
        entity.type = character.type
        entity.gender = character.gender
        entity.originName = character.origin.name
        entity.originURL = character.origin.url
        entity.locationName = character.location.name
        entity.locationURL = character.location.url
        entity.imageURL = character.image
        entity.episodeURLsArray = character.episode
        entity.createdDate = character.created
        entity.addedToFavoritesDate = Date()
    }
    
    private func removeFavorite(_ character: Character, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FavoriteCharacterEntity> = FavoriteCharacterEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", Int64(character.id))
        
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { context.delete($0) }
        } catch {
        }
    }
    
    private func loadFavorites() {
        let context = coreDataStack.viewContext
        let fetchRequest: NSFetchRequest<FavoriteCharacterEntity> = FavoriteCharacterEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addedToFavoritesDate", ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            favorites = entities.map { entityToCharacter($0) }
        } catch {
            favorites = []
        }
    }
    
    private func entityToCharacter(_ entity: FavoriteCharacterEntity) -> Character {
        return Character(
            id: Int(entity.id),
            name: entity.name,
            status: entity.status,
            species: entity.species,
            type: entity.type,
            gender: entity.gender,
            origin: Location(name: entity.originName, url: entity.originURL),
            location: Location(name: entity.locationName, url: entity.locationURL),
            image: entity.imageURL,
            episode: entity.episodeURLsArray,
            url: "",
            created: entity.createdDate
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}