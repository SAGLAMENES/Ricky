//
//  CoreDataStack.swift
//  RickyPersistance
//
//  Created by Enes on 22.10.2025.
//

import Foundation
import CoreData

/// CoreData stack manager for the application
public final class CoreDataStack: @unchecked Sendable {
    
    
    public static let shared = CoreDataStack()
    private let modelName = "RickyFavorites"
    
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.module.url(forResource: modelName, withExtension: "momd") else {
            fatalError("CoreData: Failed to find \(modelName).momd in bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("CoreData: Failed to load model from \(modelURL)")
        }
        
        return model
    }()
    
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("CoreData: Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    
    private init() {}
    
    
    public func saveContext() {
        let context = viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
        }
    }
    
    
    public func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        context.perform {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
            }
        }
    }
    
    
    public func deleteAllData() {
        let context = viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteCharacterEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
        }
    }
}

