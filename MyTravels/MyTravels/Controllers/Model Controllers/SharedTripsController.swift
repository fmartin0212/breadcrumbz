//
//  SharedTripsController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/15/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class SharedTripsController {
    
    static var shared = SharedTripsController()
    var sharedTrips = [[SharedTrip]]()
    var pendingSharedTrips = [SharedTrip]()
    var acceptedSharedTrips = [SharedTrip]()
    
    var sharedIDs = [String]()
    
    
    func addSharedIDTo(trip: Trip, forUser: User) {
        guard let userRecordID = forUser.ckRecordID else { return }
        let recordID = UsersSharedWithRecordIDs(recordID: userRecordID.recordName, isSynced: false, trip: trip)
        CoreDataManager.save()
        
        guard let updatedTripRecord = CKRecord(trip: trip) else { return }
        CloudKitManager.shared.updateOperation(records: [updatedTripRecord]) { (success) in
        }
    }
    
    func fetchUsersPendingSharedTrips(completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = UserController.shared.loggedInUser,
            let loggedInUserCKRecordID = loggedInUser.ckRecordID?.recordName
            else { completion(false) ; return }
        
        guard let pendingSharedTripsRefs = loggedInUser.pendingSharedTripsRefs else { completion(false) ; return }
        let pendingPredicate = NSPredicate(format: "recordID IN %@", pendingSharedTripsRefs)
        let query = CKQuery(recordType: "Trip", predicate: pendingPredicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching the pending shared trips in \(#function): \(error)")
            }
            
            guard let records = records else { completion(false) ; return }
            let pendingSharedTrips = records.compactMap { SharedTrip(record: $0) }
            self.sharedTrips.append(pendingSharedTrips)
            completion(true)
        }
        
        func fetchAcceptedSharedTrips(completion: @escaping (Bool) -> Void) {
            guard let loggedInUser = UserController.shared.loggedInUser
                else { completion(false) ; return }
            
            guard let acceptedSharedTripsRefs = loggedInUser.acceptedSharedTripsRefs else { completion(false) ; return }
            let acceptedPredicate = NSPredicate(format: "recordID IN %@", acceptedSharedTripsRefs)
            let query = CKQuery(recordType: "Trip", predicate: pendingPredicate)
            CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("There was an error fetching the pending shared trips in \(#function): \(error)")
                }
                
                guard let records = records else { completion(false) ; return }
                let acceptedSharedTrips = records.compactMap { SharedTrip(record: $0) }
                self.sharedTrips.append(acceptedSharedTrips)
                completion(true)
            }
        }
    }
    
    func fetchTripsSharedWithUser(completion: @escaping ([SharedTrip]) -> Void) {
        
        guard let loggedInUser = UserController.shared.loggedInUser
            else { completion([]) ; return }
        var sharedTrips = [SharedTrip]()
        
        // If the user has pending shared trips, fetch them.
        if let pendingSharedTripRefs = loggedInUser.pendingSharedTripsRefs {
            let pendingPredicate = NSPredicate(format: "recordID IN %@", pendingSharedTripRefs)
            let query = CKQuery(recordType: "Trip", predicate: NSPredicate(value: true))
            CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    print("There was an error fetching the pending shared trips in \(#function): \(error)")
                }
                
                if let records = records {
//                    let pendingSharedTrips = records.compac
                }
                
//                let acceptedPredicate = NSPredicate(format: "recordID IN %@", acceptedSharedTripsRefs)
            }
        }
      
        let query = CKQuery(recordType: "Trip", predicate: NSPredicate(value: true))
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                ("Error fetching trips shared with user. Error: \(error)")
            }
            
            guard let records = records else { completion([]) ; return }
            
            for record in records {
                guard let sharedTrip = SharedTrip(record: record) else { completion([]) ; return }
                sharedTrips.append(sharedTrip)
            }
//            self.sharedTrips = sharedTrips
            
            completion(sharedTrips)
        }
    }
    
    func fetchPlacesForSharedTrips(sharedTrips: [[SharedTrip]], completion: @escaping (Bool) -> (Void)) {
        for array in sharedTrips {
            for sharedTrip in array {
                guard let tripCKRecordID = sharedTrip.cloudKitRecordID else { completion(false) ; return }
                let predicate = NSPredicate(format: "tripReference == %@", tripCKRecordID)
                let query = CKQuery(recordType: "Place", predicate: predicate)
                CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                    if let error = error {
                        print ("There was an error fetching the trip's places. Error: \(error)")
                    }
                    
                    guard let records = records else { completion(false) ; return }
                    for record in records {
                        guard let place = SharedPlace(record: record) else { completion(false) ; return }
                        sharedTrip.places.append(place)
                    }
                })
                
            }
        }
        completion(true)
    }
}
