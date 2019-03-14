//
//  TripController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

class TripController {
    
    // MARK: - Properties
    
    static var shared = TripController()
    var frc: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
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
                        endDate: Date) -> Trip {
        
        // Initialize a trip
        let trip = Trip(name: name, location: location, tripDescription: tripDescription, startDate: startDate, endDate: endDate)
        
        // Save to Core Data
        CoreDataManager.save()
        
        return trip
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
     Calls a fetch on the fetched results controller and returns all of the trips from the persistent store. Sets the trips property on the shared instance.
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
     - parameter withReceiver: The username of the receiver.
     - parameter completion: A completion block which passes a boolean to inform the caller of whether the trip was successfully shared.
     */
    func share(trip: Trip,
               withReceiver receiveUsername: String,
               completion: @escaping (Bool) -> Void) {
        
        // Check for a logged in user
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return completion(false) }
        
        // Check to see if the receiver has blocked the loggedInUser
        self.checkIfBlocked(receiverUsername: receiveUsername) { (isBlocked) in
            if isBlocked {
                completion(false)
                return
            }
            
            if let tripID = trip.uid {
                // Trip has already been saved to the database, only a child needs to be saved on the receiver.
                self.addTripIDToReceiver(tripID: tripID, receiver: receiveUsername) { (success) in
                    if success {
                        completion(true)
                        return
                    } else {
                        print("Something went wrong with adding a tripID to a user in: ", #function)
                        completion(false)
                    }
                }
            } else {
                
                // Trip has not been saved to the database, so we need to save a new Trip child and a child on the receiver.
                let creatorName = loggedInUser.firstName
                
                self.upload(trip: trip, creatorName: creatorName) { (success) in
                    if success {
                        guard let tripID = trip.uid else { completion(false) ; return }
                        self.addTripIDToReceiver(tripID: tripID, receiver: receiveUsername, completion: { (success) in
                            if success {
                                completion(true)
                            }
                        })
                    }
                }
            }
        }
    }
    
    /**
     Creates a dictionary from the trip's properties and the trip creator's name. Creates a Firebase reference for a new child node under 'Trip.' Calls on the Firebase Manager to have the trip uploaded.
     - parameter trip: The trip to be uploaded.
     - parameter creatorName: The username of the trip creator.
     - parameter completion: A completion block which passes a boolean to indicate whether the trip was successfully saved to the Firebase database.
     */
    func upload(trip: Trip,
                creatorName: String,
                completion: @escaping (Bool) -> Void) {
        
        FirebaseManager.save(trip) { (errorMessage, tripUUID) in
            if let errorMessage = errorMessage {
                print(errorMessage)
                completion(false)
                return
            }
            trip.uuid = tripUUID
            trip.uid = trip.uuid
            CoreDataManager.save()
            
            if let tripUUID = tripUUID {
                let children = [Constants.sharedTripIDs]
                let values = [tripUUID : true]
                FirebaseManager.update(InternalUserController.shared.loggedInUser!, atChildren: children, withValues: values, completion: { (_) in
                    
                    // Save the trip's photos to Firebase storage.
                    PhotoController.shared.savePhotos(for: trip, completion: { (success) in
                        if success {
                            PlaceController.shared.uploadPlaces(for: trip, completion: { (placeIDs) in
                                let child = "placeIDs"
                                FirebaseManager.update(trip, atChildren: [child], withValues: placeIDs, completion: { (errorMessage) in
                                    if let _ = errorMessage {
                                        completion(false)
                                    } else {
                                        completion(true)
                                    }
                                })
                            })
                            
                        }
                    })
                })
            }
        }
    }
    
    /**
     Adds a shared trip ID to the receiver in the Firebase database.
     - parameter tripID: The ID of the trip that has been shared.
     - parameter receiver: The username of the receiver.
     - parameter completion: A completion block that passes a boolean to the caller to inform the caller of whether the save was successful.
     */
    func addTripIDToReceiver(tripID: String,
                             receiver: String,
                             completion: @escaping (Bool) -> Void) {
        
        FirebaseManager.fetch(uuid: nil, atChildKey: "username", withQuery: receiver) { (user: InternalUser?) in
            guard let user = user else { completion(false) ; return }
            let participantTripIDDictionary: [String : Bool] = [tripID : true]
            FirebaseManager.update(user, atChildren: ["participantTripIDs"], withValues: participantTripIDDictionary, completion: { (errorMessage) in
                if let _ = errorMessage {
                    completion(false)
                    return
                }
                completion(true)
            })
        }
    }
    
    /**
     Checks whether the logged in user is blocked by receiver.
     - parameter receiver: The username of the receiver.
     - parameter completion: A completion block which passes a boolean to inform the caller of whether the logged in user is blocked by the receiver.
     */
    func checkIfBlocked(receiverUsername: String,
                        completion: @escaping (Bool) -> Void) {
        
        FirebaseManager.fetch(uuid: nil, atChildKey: "username", withQuery: receiverUsername) { (user: InternalUser?) in
            guard let user = user, let blockedUserIDs = user.blockedUserIDs else { completion(false) ; return }
            if blockedUserIDs.contains(InternalUserController.shared.loggedInUser!.uuid!) {
                completion(true) ; return
            } else {
                completion(false)
            }
        }
    }
}


