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
    private let firebaseStorageService: FirebaseStorageServiceProtocol
    private let firestoreService: FirestoreServiceProtocol
    
    var photos: [Photo] = []
    
    init() {
        self.firebaseStorageService = FirebaseStorageService()
        self.firestoreService = FirestoreService()
    }
    
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
                    completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        // Save the trip photo to the database reference.
        saveTripPhoto(trip) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(true))
            }
        }
    }
    
    
    func saveTripPhoto(_ trip: Trip,
                       completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        guard let tripPhoto = trip.photo else { completion(.failure(.generic)) ; return }
        
        firebaseStorageService.save(tripPhoto) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let path):
                self?.firestoreService.update(object: trip, atField: "photoPath", withCriteria: [path], with: .update, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(_):
                        completion(.success(true))
                    }
                })
            }
        }
    }
    
    func savePhotos(for place: Place,
                    completion: @escaping (Bool) -> Void) {
        guard let photos = place.photos?.allObjects as? [Photo] else { completion(false) ; return }
        
        let dispatchGroup = DispatchGroup()
        for photo in photos {
            dispatchGroup.enter()
            firebaseStorageService.save(photo) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    print("Error saving crumb photo: \(error.localizedDescription)")
                    dispatchGroup.leave()
                case .success(let path):
                    dispatchGroup.enter()
                    self?.firestoreService.update(object: place, atField: "photoPaths", withCriteria: [path], with: .arrayAddition, completion: { (result) in
                        switch result {
                        case .failure(let error):
                            print("Error updating crumb: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        case .success(_):
                            dispatchGroup.leave()
                        }
                    })
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(true)
        }
    }
    
    func fetchPhoto(for trip: TripObject, completion: @escaping (Result<UIImage, FireError>) -> Void) {
        if let sharedTrip = trip as? SharedTrip {
            if let photoUID = sharedTrip.photoUID,
                photoUID != "" {
                fetchPhoto(withPath: photoUID) { (result) in
                    switch result {
                    case .success(let photo):
                        completion(.success(photo))
                    case .failure(_):
                        print("Something went wrong fetching a trip's photo")
                    }
                }
            } else {
                completion(.failure(.generic))
            }
        } else {
            let trip = trip as! Trip
            guard let photo = trip.photo else { completion(.failure(.generic)) ; return }
            completion(.success(photo.image))
        }
    }
    
    func fetchPhotos(for crumb: CrumbObject, completion: @escaping (Result<[UIImage], FireError>) -> Void) {
        if let crumb = crumb as? Place,
            let photosObjects = crumb.photos?.allObjects as? [Photo],
            photosObjects.count >= 1 {
            let photos = photosObjects.compactMap { UIImage(data: $0.data) }
            completion(.success(photos))
            return
        }
        guard let sharedCrumb = crumb as? SharedPlace,
            let photoPaths = sharedCrumb.photoUIDs,
            photoPaths.count > 0
            else { completion(.failure(.generic)) ; return }
        var photoDatum: [Data] = []
        let dispatchGroup = DispatchGroup()
        for photoPath in photoPaths {
            dispatchGroup.enter()
            firebaseStorageService.fetchFromStorage(path: photoPath) { (result) in
                switch result {
                case .failure(_):
                    dispatchGroup.leave()
                case .success(let photoData):
                    photoDatum.append(photoData)
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            let photos = photoDatum.compactMap { UIImage(data: $0) }
            completion(.success(photos))
        }
    }
    
    func fetchPhoto(withPath path: String,
                    completion: @escaping (Result<UIImage, FireError>) -> Void) {
        firebaseStorageService.fetchFromStorage(path: path) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let image = UIImage(data: data) else { completion(.failure(.generic)) ; return }
                image.addToImageCache(path: path)
                completion(.success(image))
            }
        }
    }
    
    func savePhoto(photo: UIImage,
                   for user: InternalUser,
                   completion: @escaping (Result<Bool, FireError>) -> Void) {
        guard let imageAsData = photo.jpegData(compressionQuality: 0.1) else { completion(.failure(.generic)) ; return }
        
        let photo = Photo(photo: imageAsData, place: nil, trip: nil)
        
        firebaseStorageService.save(photo) { [weak self] (result) in
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let path):
                self?.firestoreService.update(object: user, atField: "photoPath", withCriteria: [path], with: .update, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(_):
                        CoreDataManager.delete(object: photo)
                        completion(.success(true))
                    }
                })
            }
        }
    }
    
    func updatePhoto(for trip: Trip, with image: UIImage) {
        
    }
}



