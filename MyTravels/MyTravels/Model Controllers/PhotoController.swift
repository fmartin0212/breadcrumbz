//
//  PhotoController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/5/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

class PhotoController {
    
    static var shared = PhotoController()
    
    var frc: NSFetchedResultsController<Photo> = {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photo", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    // Add photo to place
    func add(photos: [Data], place: Place) {
        for photo in photos {
            let newPhoto = Photo(photo: photo, place: place, trip: nil)
            print(newPhoto)
        }
        saveToPersistentStore()
    }
    
    // Add photo to trip
    func add(photo: Data, trip: Trip) {
        let newPhoto = Photo(photo: photo, place: nil, trip: trip)
        saveToPersistentStore()
    }
    
    
    // Save to Core Data
    func saveToPersistentStore() {
        
        do {
            try CoreDataStack.context.save()
        } catch let error {
            print("Error saving Managed Object Context (Photo): \(error)")
        }
        
    }
    
}
