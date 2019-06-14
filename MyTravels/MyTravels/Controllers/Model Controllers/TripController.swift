//
//  TripController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData
import PSOperations

class TripController {
    
    // MARK: - Properties
    
    static var shared = TripController()
    var frc: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var trips: [Trip] = []
    let firestoreService: FirestoreServiceProtocol
    let firebaseStorageService: FirebaseStorageServiceProtocol
    let operationQueue = PSOperationQueue()
    
    init() {
        self.firestoreService = FirestoreService()
        self.firebaseStorageService = FirebaseStorageService()
    }
    
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
    
    func update(trip: Trip,
                with photo: Photo?,
                name: String,
                location: String,
                tripDescription: String?,
                startDate: Date,
                endDate: Date,
                completion: @escaping (Result<Bool, FireError>) -> Void) {
        trip.photo = photo
        trip.name = name
        trip.location = location
        trip.tripDescription = tripDescription
        trip.startDate = startDate as NSDate
        trip.endDate = endDate as NSDate
        
        
        
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
               withReceiver receiverUsername: String,
               completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        // Check for a logged in user
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { completion(.failure(.generic)) ; return }
        
        if trip.uid != nil {
            // Trip has already been saved to the database, only a child needs to be saved on the receiver.
            let shareTripOperation = ShareTripOperation(trip: trip, service: firestoreService, storageService: firebaseStorageService, receiverUsername: receiverUsername) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(_):
                    print("asd")
                    completion(.success(true))
                }
            }
            operationQueue.addOperation(shareTripOperation)
        } else {
            
            // Trip has not been saved to the database, so we need to save a new Trip child and a child on the receiver.
            let creatorName = loggedInUser.firstName
            
            self.upload(trip: trip, receiverUUID: receiverUsername, creatorName: creatorName) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(_):
                    print("asd")
                    completion(.success(true))
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
                receiverUUID: String,
                creatorName: String,
                completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        guard InternalUserController.shared.loggedInUser != nil else { completion(.failure(.generic)) ; return }
        
        let save = SaveTripOperation(trip: trip, receiverUsername: receiverUUID, service: firestoreService, storageService: firebaseStorageService, completion: completion)
        
        operationQueue.addOperation(save)
    }
    
    /**
     Adds a shared trip ID to the receiver in the Firebase database.
     - parameter tripID: The ID of the trip that has been shared.
     - parameter receiver: The username of the receiver.
     - parameter completion: A completion block that passes a boolean to the caller to inform the caller of whether the save was successful.
     */
    func addTripIDToReceiver(for trip: Trip,
                             receiver: String,
                             completion: @escaping (Result<Bool, FireError>) -> Void) {
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { completion(.failure(.generic)) ; return }
        
        firestoreService.fetch(uuid: nil, field: "username", criteria: receiver, queryType: .fieldEqual, completion: { [weak self] (result: Result<[InternalUser], FireError>) in
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let internalUserArray):
                guard internalUserArray.count > 0,
                    let internalUser = internalUserArray.first
                    else { completion(.failure(.generic)) ; return }
                self?.firestoreService.update(object: internalUser, fieldsAndCriteria: ["tripsFollowingIDs" : trip.uid ?? ""], with: .update, completion: { (result) in
                    switch result {
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .success(_):
                        self?.firestoreService.update(object: trip, fieldsAndCriteria: ["followers" : [loggedInUser.uuid ?? ""]], with: .arrayAddition, completion: { (result) in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(_):
                                completion(.success(true))
                            }
                        })
                    }
                })
            }
        })
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




