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
                    FirebaseManager.update(object: InternalUserController.shared.loggedInUser!, atChildren: children, withValues: values, completion: { (_) in

                        // Save the trip's photos to Firebase storage.
                        PhotoController.shared.savePhotos(for: trip, completion: { (success) in
                            if success {
                                completion(true)
                            }
                        })
                    })
                }
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
        
        // Get a database reference to the receiver's participant trip ID child node.
        let userTripRef = Constants.databaseRef.child(Constants.user).child(receiver).child(Constants.participantTripIDs)
        
        // Save the trip ID to the database reference.
        let value = [tripID : true]
        FirebaseManager.update(at: userTripRef, value: value) { (_) in
          print("break")
            completion(true)
        }
    }
    
    /**
     Checks whether the logged in user is blocked by receiver.
     - parameter receiver: The username of the receiver.
     - parameter completion: A completion block which passes a boolean to inform the caller of whether the logged in user is blocked by the receiver.
    */
    func checkIfBlocked(_ receiver: String,
                        completion: @escaping (Bool) -> Void) {
        
        // Get a database reference to the receiver's blocked usernames.
        let ref = FirebaseManager.ref.child("User").child(receiver).child("blockedUsernames")
        
        // Fetches all of the receiver's blocked usernames from the Firebase database.
        FirebaseManager.fetchObject(from: ref) { (snapshot) in
            guard let blockedUsernames = snapshot.value as? [String : String] else { completion(false) ; return }
            
            // Loops through each username dictionary, checking if the logged in user's username is blocked by the receiver.
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


