//
//  PlaceController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

class PlaceController {
    
    // MARK: - Properties
    
    var frc: NSFetchedResultsController<Place> = {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    static var shared = PlaceController()
    let firestoreService: FirestoreServiceProtocol
    init() {
        firestoreService = FirestoreService()
    }
}

extension PlaceController {
    
    /**
     Creates a new place and saves it to Core Data. A 'place' is known as a crumb in the app.
     - parameter name: The name of the place.
     - parameter type: The type of place (Restaurant, Lodging, or Activity).
     - parameter address: The address of the place.
     - parameter comments: The user's comments about the place.
     - parameter rating: The place's rating ranging from 1-5.
     - parameter trip: The trip that the place belongs to.
     */
    @discardableResult func createNewPlaceWith(name: String,
                type: Place.types,
                address: String,
                comments: String,
                rating: Int16,
                trip: Trip) -> Place {
        
        // Initialize a new place
        let newPlace = Place(name: name, address: address, comments: comments, rating: rating, trip: trip)
        let _ = PlaceType(type: type, place: newPlace)
        // Save the Core Data MOC.
        CoreDataManager.save()
        
        return newPlace
    }
    
    /** Updates an existing place and saves it to Core Data. A 'place' is known as a crumb in the app.
    - parameter name: The name of the place.
    - parameter type: The type of place (Restaurant, Lodging, or Activity).
    - parameter address: The address of the place.
    - parameter comments: The user's comments about the place.
    - parameter rating: The place's rating ranging from 1-5.
    - parameter trip: The trip that the place belongs to.
    */
    func update(place: Place,
                name: String,
                type: Place.types,
                address: String,
                comments: String,
                rating: Int16) {
        
        // Update the place's properties.
        place.name = name
        place.address = address
        place.comments = comments
        place.rating = rating
        
        if let placeType = place.placeType {
            placeType.type = type.rawValue
        }
        
        // Save the Core Data MOC.
        CoreDataManager.save()
    }
    
    /**
     Deletes a place from the Core Data MOC.
     - parameter place : The place to be deleted.
     */
    func delete(place: Place) {
        CoreDataManager.delete(object: place)
    }
    
    func uploadPlaces(for trip: Trip,
                      completion: @escaping ([String]) -> Void) {
        
        guard let places = trip.places?.allObjects as? [Place],
            places.count > 0
            else { completion([]) ; return }
        let dispatchGroup = DispatchGroup()
        for place in places {
            dispatchGroup.enter()
            var crumbIDs: [String] = []
            firestoreService.save(object: place) { (result) in
                switch result {
                case .failure(let error):
                    print("Error saving crumb: \(error.localizedDescription)")
                    dispatchGroup.leave()
                case .success(let uuid):
                    place.uuid = uuid
                    crumbIDs.append(uuid)
                    dispatchGroup.leave()
                }
            }
        }
            
        dispatchGroup.notify(queue: .main) {
            let secondDispatchGroup = DispatchGroup()
            for place in places {
                secondDispatchGroup.enter()
                PhotoController.shared.savePhotos(for: place, completion: { (success) in
                    secondDispatchGroup.leave()
                })
            }
            secondDispatchGroup.notify(queue: .main, execute: {
                completion([])
            })
        }
    }
    
    
    func upload(_ place: Place,
                completion: @escaping (String?) -> Void)  {
        FirebaseManager.save(place) { (errorMessage, uuid) in
            if let _ = errorMessage {
                completion(nil)
                return
            } else {
                completion(uuid)
            }
        }
    }
}

