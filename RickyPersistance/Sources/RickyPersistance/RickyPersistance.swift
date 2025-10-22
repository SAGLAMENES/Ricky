//
//  RickyPersistance.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

// Export public types
@_exported import CoreData

// This module provides persistence layer with CoreData and caching
// - CoreDataStack: Manages CoreData persistent container
// - FavoriteCharacterEntity: CoreData entity for favorite characters
// - MemoryCache: In-memory LRU cache
// - DiskCache: File-based persistent cache
// - FavoritesRepository: Repository for managing favorites
