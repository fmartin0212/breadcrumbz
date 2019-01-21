//
//  PhotoController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/5/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import FirebaseStorage

final class PhotoController {
    
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
    
    /**
     Initializes a new photo and saves the Core Data MOC.
     - parameter photo: The photo as data to be saved.
     - parameter trip: The trip that the photo belongs to.
     */
    func add(photo: Data, trip: Trip) {
        
        // Initialize a new Photo.
        let _ = Photo(photo: photo, place: nil, trip: trip)
        
        // Save the Core Data MOC.
        CoreDataManager.save()
    }
    
    /**
     Loops over the photos parameter and initializes a new photo object. Saves the Core Data MOC.
     - parameter photos: The array of photos as data to be saved.
     - parameter place: The place that the photos belong to.
     */
    func add(photos: [Data], place: Place) {
        
        // Loop over the photos and initialize a Photo.
        for photo in photos {
            //            let _ = Photo(
            let _ = Photo(photo: photo, place: place, trip: nil)
        }
        
        // Save the Core Data MOC.
        CoreDataManager.save()
    }
    
    /**
     Removes all of the photos from the Core Data MOC.
     - parameter photos: The array of photos as data to be saved.
     - parameter place: The place that the photos belong to.
     */
    func update(photos: [Data], for place: Place) {
        guard let photoArray = place.photos?.allObjects as? [Photo] else { return }
        
        // Remove all of the existing photos from the place.
        for photo in photoArray {
            photo.managedObjectContext?.delete(photo)
        }
        
        // Initialize a new photo for each photo in the photos array.
        for photo in photos {
            let _ = Photo(photo: photo, place: place, trip: nil)
        }
        
        // Save the Core Data MOC.
        CoreDataManager.save()
    }
    
    /**
     Deletes the Photo from the Core Data MOC.
     - parameter photo: The photo to be deleted.
     */
    func delete(photo: Photo) {
        CoreDataManager.delete(object: photo)
    }
    
    // MARK: - Firebase
    
    /**
     Calls savePhotos and savePlacePhotos to save the trip photo and the place photos to Firebase Storage.
     - parameter trip: The trip that the photos are being saved for.
     - parameter completion: A completion block that passes a boolean which informs the caller of whether the photos were successfully saved to Firebase Storage.
     */
    func savePhotos(for trip: Trip,
                    completion: @escaping (Bool) -> Void) {
        
        // Save the trip photo to the database reference.
        saveTripPhoto(trip) { (success) in
            if success {
                
                // Save the trip's places' photos.
                self.savePlacePhotos(for: trip, completion: { (success) in
                    if success {
                        completion(true)
                    }
                })
            }
        }
    }
    
    func saveTripPhoto(_ trip: Trip,
                       completion: @escaping (Bool) -> Void) {
        
        guard let tripPhoto = trip.photo else { completion(false) ; return }
        
        FirebaseManager.save(tripPhoto) { (metadata, errorMessage) in
            if let _ = errorMessage {
                completion(false)
            } else if let metadata = metadata {
                metadata.downloadURL()
                let children = [Constants.photoURL]
                let values = [tripPhoto.uid! : true]
                
                FirebaseManager.update(trip, atChildren: children, withValues: values, completion: { (errorMessage) in
                    if let _ = errorMessage {
                        completion(false)
                        return
                    } else {
                        completion(false)
                    }
                })
            }
        }
    }
    
    func savePlacePhotos(for trip: Trip,
                         completion: @escaping (Bool) -> Void) {
        // FIXME : - Need to update completions/error messages
        if let places = trip.places?.allObjects as? [Place] {
            
            for place in places {
                
                if let photos = place.photos?.allObjects as? [Photo] {
                    
                    let dispatchGroup = DispatchGroup()
                    
                    let photoDictionary = [String : Any]()
                    
                    for photo in photos {
                        
                        dispatchGroup.enter()
                        
                        FirebaseManager.save(photo) { (metadata, errorMessage) in
                            if let _ = errorMessage {
                                
                            }
                            
                            let value: [String : Any] = [photo.uid! : metadata?.downloadURL()?.absoluteString as Any]
                            
                            dispatchGroup.enter()
                            
                            let databaseRef = Constants.databaseRef.child(Constants.trip).child(trip.uid!).child(Constants.places).child(place.name)
                            
                            FirebaseManager.updateObject(at: databaseRef, value: value, completion: { (errorMessage) in
                                if let _ = errorMessage {
                                    
                                }
                            })
                            FirebaseManager.save(photoDictionary, to: databaseRef, completion: { (error) in
                                if let error = error {
                                    print(error)
                                    
                                }
                                dispatchGroup.leave()
                            })
                            dispatchGroup.leave()
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        completion(true)
                    }
                }
            }
        }
    }
}
