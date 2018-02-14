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
    static var shared = PlaceController()
    var frc: NSFetchedResultsController<Place> = {
        let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    
    }()
    
    var place: Place?
    var places: [Place] = []
    
    // CRUD Functions
    // Create
    func create(name: String, type: String, address: String, comments: String, rating: Int16, trip: Trip) {
        let newPlace = Place(name: name, type: type, address: address, comments: comments, rating: rating, trip: trip)
        self.place = newPlace
        saveToPersistentStore()
        
    }
    
    // Update
    func update(place: Place, name: String, type: String, address: String, comments: String, rating: Int16, trip: Trip) {
       
        place.name = name
        place.type = type
        place.address = address
        place.comments = comments
        place.rating = rating
        place.trip = trip
        
        self.place = place
        
        saveToPersistentStore()
        
    }
    
    // Delete
    func delete(place: Place) {
        place.managedObjectContext?.delete(place)
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.context.save()
        } catch let error {
            print("Error saving Managed Object Context (Place): \(error)")
            
        }
    }
}
