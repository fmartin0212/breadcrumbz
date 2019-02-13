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
//    
//    init() {
//        
//    }
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
    func createNewPlaceWith(name: String,
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
    
    /**
     Loops over a trip's places and creates dictionaries for each one so that they can be saved to Firebase. Adds each dictionary to a parent dictionary and returns it to the caller.
     - parameter trip: The trip which places are being turned into dictionaries.
     
     */
    func createPlaces(for trip: Trip) -> [String : [String : Any]]? {
        
        // Unwrap the trip's places and cast them as an array
        guard let places = trip.places?.allObjects as? [Place], places.count > 0 else { return nil }
        
        // Create an empty dictionary. The 'parent' dictionary.
        var placesDict = [String : [String : Any]]()
        
        // Loop through each place and create a new dictionary using the place's properties.
        for place in places {

            // Add the new place to the 'parent' dictionary using the place's name as a key.
            placesDict[place.name] = place.dictionary
            
        }
        
        return placesDict
    }
}

