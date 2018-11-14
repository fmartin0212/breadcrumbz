//
//  TripController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData
import FirebaseDatabase

class TripController {
    
    // MARK: - Properties
    static var shared = TripController()
    var frc: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var trip: Trip?
    var trips: [Trip] = []
    
    // MARK: - CRUD Functions
    // Create
    func createTripWith(name: String, location: String, tripDescription: String?, startDate: Date, endDate: Date) {
        let trip = Trip(name: name, location: location, tripDescription: tripDescription, startDate: startDate, endDate: endDate)
        self.trip = trip
        CoreDataManager.save()
    }

    func delete(trip: Trip) {
        CoreDataManager.delete(object: trip)
    }
    
    func fetchAllTrips() {
        do {
            try frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
        }
        
        guard let trips = frc.fetchedObjects else { return }
        self.trips = trips
    }
    
    func share(trip: Trip, withReceiver receiver: String, completion: @escaping (Bool) -> Void) {
        
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return completion(false) }
        // PRESENT ALERT CONTROLLER OR CREATE ACCOUNT
        
        if let tripID = trip.id {
            
            // Trip has already been saved to the database, only a child needs to be saved on the receiver.
            addTripIDToReceiver(tripID: tripID, receiver: receiver) { (success) in
                if success {
                    completion(true)
                    return
                } else {
                    print("Something went wrong with adding a tripID to a user in: ", #function)
                }
            }
            
        } else {
            
            // Trip has not been saved in the database, so we need to save a new Trip child and a child on the receiver.
            let creatorName = loggedInUser.firstName + " " + (loggedInUser.lastName ?? "")
            
            upload(trip: trip, creatorName: creatorName) { (success) in
                if success {
                    guard let tripID = trip.id else { completion(false) ; return }
                    self.addTripIDToReceiver(tripID: tripID, receiver: receiver, completion: { (success) in
                        if success {
                            completion(true)
                        }
                    })
                }
            }
        }
    }
    
    func upload(trip: Trip, creatorName: String, completion: @escaping (Bool) -> Void) {
        
        let tripDict: [String : Any?] = [
            "name" : trip.name,
            "location" : trip.location,
            "description" : trip.tripDescription,
            "startDate" : trip.startDate.timeIntervalSince1970,
            "endDate" : trip.endDate.timeIntervalSince1970,
            "creatorName" : creatorName,
            "places" : PlaceController.shared.createPlaces(for: trip)
        ]
    
        let tripRef = FirebaseManager.ref.child("Trip").childByAutoId()
        
        FirebaseManager.save(object: tripDict, to: tripRef) { (error) in
            if let _ = error {
                completion(false)
                return
            }
            
            let sharedTripIDRef = FirebaseManager.ref.child("User").child(InternalUserController.shared.loggedInUser!.username).child("sharedTripIDs").child(tripRef.key)
            let sharedTripIDDict = ["sharedID" : tripRef.key]
            FirebaseManager.save(object: sharedTripIDDict, to: sharedTripIDRef, completion: { (error) in
                if let error = error {
                    print("There was an error saving the shared trip ID to the 'sharer': \(error.localizedDescription)")
                }
            })
            
            
            // If save to Firebase is successful, save trip's UID locally and to persistent store.
            trip.id = tripRef.key
            CoreDataManager.save()
            
            PhotoController.shared.savePhotos(for: trip, completion: { (success) in
                if success {
                    completion(true)
                }
            })
        }
    }
    
    func addTripIDToReceiver(tripID: String, receiver: String, completion: @escaping (Bool) -> Void) {
        let userTripRef = FirebaseManager.ref.child("User").child(receiver).child("participantTripIDs").child(tripID)
        
        FirebaseManager.saveSingleObject(tripID, to: userTripRef, completion: { (error) in
            if let error = error {
                print(error)
                completion(false)
            }
            completion(true)
        })
    }
}


