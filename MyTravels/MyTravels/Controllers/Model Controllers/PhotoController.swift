//
//  PhotoController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/5/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class PhotoController {
    
    // MARK: - Properties
    static var shared = PhotoController()
    var tripPhoto: Photo?
    var frc: NSFetchedResultsController<Photo> = {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photo", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
    }()
    
    var photos: [Photo] = []
    
    // CRUD Functions
    // Add photo to place
    func add(photos: [Data], place: Place) {
        
        for photo in photos {
            let newPhoto = Photo(photo: photo, place: place, trip: nil)
    
        }
        saveToPersistentStore()
        
    }
    
    func update(photos: [Data], forPlace: Place) {
        
        guard let photoArray = forPlace.photos?.allObjects as? [Photo] else { return }
        
        for photo in photoArray {
            photo.managedObjectContext?.delete(photo)
        }
        print ("adsf")
        for photo in photos {
            let newPhoto = Photo(photo: photo, place: forPlace, trip: nil)
            
        }
        saveToPersistentStore()
        
    }
    
    // Add photo to trip
    func add(photo: Data, trip: Trip) {
        
        let newPhoto = Photo(photo: photo, place: nil, trip: trip)
        saveToPersistentStore()
        
    }
    
    // Delete a photo
    func delete(photo: Photo) {
        photo.managedObjectContext?.delete(photo)
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
    
    // CloudKit
    func fetchPhotoFor(trip: SharedTrip, completion: @escaping (Bool) -> (Void)) {
        guard let tripCloudKitRecordID = trip.cloudKitRecordID
            else { completion(false) ; return }
        let predicate = NSPredicate(format: "tripReference == %@", tripCloudKitRecordID)
        let query = CKQuery(recordType: "Photo", predicate: predicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error retrieving photo for trip. Error: \(error)")
            }
            guard let tripPhotoRecord = records?.first,
                let tripPhoto = Photo(record: tripPhotoRecord, context: CoreDataStack.context)
                else { completion(false) ; return }
                self.tripPhoto = tripPhoto
                PhotoController.shared.delete(photo: tripPhoto)
        }
        completion(true)
    }
    
    
}
