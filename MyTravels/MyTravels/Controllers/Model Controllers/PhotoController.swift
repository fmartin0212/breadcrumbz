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
    
    // MARK: - Firebase
    
    func savePhotos(for trip: Trip, completion: @escaping (Bool) -> Void) {
        let storeRef = FirebaseManager.storeRef.child("Trip").child(trip.uid!)
        saveTripPhoto(trip: trip, storeRef: storeRef) { (success) in
            if success {
                self.savePlacePhotos(for: trip, to: storeRef, completion: { (success) in
                    if success {
                        completion(true)
                    }
                })
            }
        }
    }
    
    func savePlacePhotos(for trip: Trip, to storeRef: StorageReference, completion: @escaping (Bool) -> Void) {
        
        if let places = trip.places?.allObjects as? [Place] {
            
            for place in places {
                
                if let photos = place.photos?.allObjects as? [Photo] {
                    
                    let dispatchGroup = DispatchGroup()
                    
                    for photo in photos {
                        
                        let photoDBRef = FirebaseManager.ref.child("Trip").child(trip.uid!).child("places").child(place.name).child("photoURLs").childByAutoId()
                        let photoRef = storeRef.child("Places").child(place.name).child(photoDBRef.key)
                        
                        guard let photoData = photo.photo
                            else { completion(false) ; return }
                        
                        let data = Data(referencing: photoData)
                        
                        dispatchGroup.enter()
                        FirebaseManager.save(data: data, to: photoRef) { (metadata, error) in
                            
                            photo.uid = photoRef.name
                            CoreDataManager.save()
                            
                            let photoDictionary: [String : Any] = [photo.uid! : metadata?.downloadURL()?.absoluteString as Any]
                            
                            dispatchGroup.enter()
                            FirebaseManager.save(object: photoDictionary, to: photoDBRef, completion: { (error) in
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

    func saveTripPhoto(trip: Trip, storeRef: StorageReference, completion: @escaping (Bool) -> Void) {
        guard let tripPhoto = trip.photo?.photo else { completion(false) ; return }
        let data = Data(referencing: tripPhoto)
        
        FirebaseManager.save(data: data, to: storeRef) { (_, error) in
            completion(true)
        }
    }
}
