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
    func add(photos: [Int : Data], place: Place) {
        
        // Loop over the photos and initialize a Photo.
        for (_, photo) in photos {
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
    func update(photos: [Int : Data], for place: Place) {
        guard let photoArray = place.photos?.allObjects as? [Photo] else { return }
        
        // Remove all of the existing photos from the place.
        for photo in photoArray {
            CoreDataManager.delete(object: photo)
        }
        
        // Initialize a new photo for each photo in the photos array.
        for (_, photo) in photos {
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
                //                self.savePlacePhotos(for: trip, completion: { (success) in
                completion(true)
                //                })
            }
        }
    }
    
    func saveTripPhoto(_ trip: Trip,
                       completion: @escaping (Bool) -> Void) {
        
        guard let tripPhoto = trip.photo else { completion(true) ; return }
        
        FirebaseManager.save(tripPhoto) { (metadata, errorMessage) in
            if let _ = errorMessage {
                completion(false)
            } else if let _ = metadata {
                let children = [Constants.photoID]
                let values = [tripPhoto.uid : true]
                
                FirebaseManager.update(trip, atChildren: children, withValues: values, completion: { (errorMessage) in
                    if let _ = errorMessage {
                        completion(false)
                        return
                    } else {
                        completion(true)
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
                            
                            let value: [String : Any] = [photo.uid : metadata?.path as Any]
                            
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
        completion(true)
    }
    
    func savePhotos(for place: Place,
                    completion: @escaping (Bool) -> Void) {
        guard let photos = place.photos?.allObjects as? [Photo] else { completion(false) ; return }
        
        let dispatchGroup = DispatchGroup()
        var photoDict: [String : Any] = [:]
        var int = 0
        for photo in photos {
            int += 1
            dispatchGroup.enter()
            FirebaseManager.save(photo) { (metadata, _) in
                if let metadata = metadata {
                    let downloadURL = metadata.path
                    photoDict[String(int)] = downloadURL!
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            let child = "photoURLs"
            FirebaseManager.update(place, atChildren: [child], withValues: photoDict, completion: { (errorMessage) in
                if let _ = errorMessage {
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }
    }
    
    func fetchPhotos(for crumb: CrumbObject, completion: @escaping ([UIImage]?) -> Void) {
        if let crumb = crumb as? Place,
            let photosObjects = crumb.photos?.allObjects as? [Photo],
            photosObjects.count >= 1 {
            let photos = photosObjects.compactMap { UIImage(data: $0.data) }
            completion(photos)
            return
        }
        guard let sharedCrumb = crumb as? SharedPlace,
            let photoURLs = sharedCrumb.photoURLs,
            photoURLs.count > 0
            else { completion(nil) ; return }
        var photos: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        for photoURL in photoURLs {
            dispatchGroup.enter()
            let dataTask = URLSession.shared.dataTask(with: URL(string: photoURL)!) { (data, _, error) in
                if let _ = error {
                    dispatchGroup.leave()
                }
                guard let data = data,
                    let photo = UIImage(data: data)
                    else { return }
                photos.append(photo)
                dispatchGroup.leave()
                
            }
            dataTask.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(photos)
        }
    }
}


