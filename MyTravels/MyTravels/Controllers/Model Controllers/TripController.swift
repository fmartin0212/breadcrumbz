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
    
    /**
     Initializes a Trip object into the Managed Object Context, and saves it to the persistent store.
     - parameter name: The name of the trip.
     - parameter location: The location of the trip.
     - parameter tripDescription: An optional description of the trip.
     - parameter startDate: The start date of the trip.
     - parameter endDate: The end date of the trip.
    */
    func createTripWith(name: String,
                        location: String,
                        tripDescription: String?,
                        startDate: Date,
                        endDate: Date) {
        
        // Initialize a trip
        let trip = Trip(name: name, location: location, tripDescription: tripDescription, startDate: startDate, endDate: endDate)
        
        // Set the shared instance's global trip reference
        self.trip = trip
        
        // Save to Core Data
        CoreDataManager.save()
    }
    
    /**
     Deletes a trip from the Core Data persistent store.
     - parameter trip: The trip to be deleted.
    */
    func delete(trip: Trip) {
        
        // Delete from Core Data
        CoreDataManager.delete(object: trip)
    }
    
    /**
     Calls a fetch on the fetched results controller and returns all of the Trips from the persistent store.
    */
    func fetchAllTrips() {
        
        // Perform the fetch
        do {
            try frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
        }
        
        guard let trips = frc.fetchedObjects else { return }
        
        // Set the shared instance's trips array
        self.trips = trips
    }
    
    /**
     Shares a trip with another user.
     - parameter trip: The trip being shared.
     - parameter withReceiver: The username that is receiving the trip.
     -
    */
    func share(trip: Trip,
               withReceiver receiver: String,
               completion: @escaping (Bool) -> Void) {
        
        // Check for a logged in user
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return completion(false) }
        
        // Check to see if the receiver has blocked the loggedInUser
        self.checkIfBlocked(receiver) { (isBlocked) in
            if isBlocked {
                completion(false)
                return
            }
            
            if let tripID = trip.uid {
                
                // Trip has already been saved to the database, only a child needs to be saved on the receiver.
                self.addTripIDToReceiver(tripID: tripID, receiver: receiver) { (success) in
                    if success {
                        completion(true)
                        return
                    } else {
                        print("Something went wrong with adding a tripID to a user in: ", #function)
                    }
                }
                
            } else {
                
                // Trip has not been saved to the database, so we need to save a new Trip child and a child on the receiver.
                let creatorName = loggedInUser.firstName + " " + (loggedInUser.lastName ?? "")
                
                upload(trip: trip, creatorName: creatorName) { (success) in
                    if success {
                        guard let tripID = trip.uid else { completion(false) ; return }
                        self.addTripIDToReceiver(tripID: tripID, receiver: receiver, completion: { (success) in
                            if success {
                                completion(true)
                            }
                        })
                    }
                }
            }
        }
        
        /**
         Creates a dictionary from the trip's properties and the trip creator's name. Creates a Firebase reference for a new child node under 'Trip.' Calls on the Firebase Manager to have the trip uploaded.
         - parameter trip: The trip to be uploaded.
         - parameter creatorName: The username of the trip creator.
        */
        func upload(trip: Trip,
                    creatorName: String,
                    completion: @escaping (Bool) -> Void) {
            
            // Initialize a dictionary based on the trip's properties and the trip creator's name.
            let tripDict: [String : Any?] = [
                "name" : trip.name,
                "location" : trip.location,
                "description" : trip.tripDescription,
                "startDate" : trip.startDate.timeIntervalSince1970,
                "endDate" : trip.endDate.timeIntervalSince1970,
                "creatorName" : creatorName,
                "creatorUsername" : loggedInUser.username,
                "places" : PlaceController.shared.createPlaces(for: trip)
            ]
            
            let tripRef = FirebaseManager.ref.child("Trip").childByAutoId()
            
            FirebaseManager.save(object: tripDict, to: tripRef) { (error) in
                if let _ = error {
                    completion(false)
                    return
                }
                
                let sharedTripIDRef = FirebaseManager.ref.child("User").child(InternalUserController.shared.loggedInUser!.username).child("sharedTripIDs").child(tripRef.key)
                FirebaseManager.saveSingleObject(tripRef.key, to: sharedTripIDRef, completion: { (error) in
                    if let error = error {
                        print("There was an error saving the shared trip ID to the 'sharer': \(error.localizedDescription)")
                    }
                })
                
                // If save to Firebase is successful, save trip's UID locally and to persistent store.
                trip.uid = tripRef.key
                CoreDataManager.save()
                
                PhotoController.shared.savePhotos(for: trip, completion: { (success) in
                    if success {
                        completion(true)
                    }
                })
            }
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
    
    func checkIfBlocked(_ receiver: String, completion: @escaping (Bool) -> Void) {
        let ref = FirebaseManager.ref.child("User").child(receiver).child("blockedUsernames")
        FirebaseManager.fetchObject(from: ref) { (snapshot) in
            guard let blockedUsernames = snapshot.value as? [String : String] else { completion(false) ; return }
            for (username, _) in blockedUsernames {
                if username == InternalUserController.shared.loggedInUser!.username {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
}


