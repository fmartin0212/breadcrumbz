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
 
    func add(photo: Data, trip: Trip) {
        let _ = Photo(photo: photo, place: nil, trip: trip)
        CoreDataManager.save()
    }

    func add(photos: [Data], place: Place) {
        for photo in photos {
            let _ = Photo(photo: photo, place: place, trip: nil)
        }
        CoreDataManager.save()
    }
    
    func update(photos: [Data], forPlace: Place) {
        guard let photoArray = forPlace.photos?.allObjects as? [Photo] else { return }
        
        for photo in photoArray {
            photo.managedObjectContext?.delete(photo)
        }
        for photo in photos {
            let _ = Photo(photo: photo, place: forPlace, trip: nil)
        }
        CoreDataManager.save()
    }
    
    func delete(photo: Photo) {
        CoreDataManager.delete(object: photo)
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
