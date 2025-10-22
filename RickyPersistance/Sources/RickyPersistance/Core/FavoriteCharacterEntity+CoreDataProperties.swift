//
//  FavoriteCharacterEntity+CoreDataProperties.swift
//  RickyPersistance
//
//  Created by Enes on 22.10.2025.
//

import Foundation
import CoreData

extension FavoriteCharacterEntity {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCharacterEntity> {
        return NSFetchRequest<FavoriteCharacterEntity>(entityName: "FavoriteCharacterEntity")
    }
    
    // MARK: - Properties
    
    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var status: String
    @NSManaged public var species: String
    @NSManaged public var type: String
    @NSManaged public var gender: String
    @NSManaged public var originName: String
    @NSManaged public var originURL: String
    @NSManaged public var locationName: String
    @NSManaged public var locationURL: String
    @NSManaged public var imageURL: String
    @NSManaged public var episodeURLs: String // JSON string array
    @NSManaged public var createdDate: String
    @NSManaged public var addedToFavoritesDate: Date
    
    // MARK: - Convenience
    
    public var episodeURLsArray: [String] {
        get {
            guard let data = episodeURLs.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                episodeURLs = string
            }
        }
    }
}


