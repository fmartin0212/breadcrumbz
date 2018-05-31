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
    var sharedTrips: [[SharedTrip]] = []
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
        guard let loggedInUser = UserController.shared.loggedInUser
            else { completion(false) ; return }
        if loggedInUser.pendingSharedTripsRefs.count == 0 {
            completion(false)
            return
        }
//        guard let pendingSharedTripsRefs = loggedInUser.pendingSharedTripsRefs else { completion(false) ; return }
        let pendingPredicate = NSPredicate(format: "recordID IN %@", loggedInUser.pendingSharedTripsRefs)
        let query = CKQuery(recordType: "Trip", predicate: pendingPredicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching the pending shared trips in \(#function): \(error)")
            }
            
            guard let records = records else { completion(false) ; return }
            
            self.pendingSharedTrips = records.compactMap { SharedTrip(record: $0) }
            for pendingSharedTrip in self.pendingSharedTrips {
                pendingSharedTrip.isAcceptedTrip = false
            }
            
            self.sharedTrips.append(self.pendingSharedTrips)
            completion(true)
        }
    }
    
    func fetchAcceptedSharedTrips(completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = UserController.shared.loggedInUser
            else { completion(false) ; return }
        if loggedInUser.acceptedSharedTripsRefs.count == 0 {
            completion(false)
            return
        }
//        guard let acceptedSharedTripsRefs = loggedInUser.acceptedSharedTripsRefs else { completion(false) ; return }
        let acceptedPredicate = NSPredicate(format: "recordID IN %@", loggedInUser.acceptedSharedTripsRefs)
        let query = CKQuery(recordType: "Trip", predicate: acceptedPredicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error fetching the pending shared trips in \(#function): \(error)")
            }
            
            guard let records = records else { completion(false) ; return }
            
            self.acceptedSharedTrips = records.compactMap { SharedTrip(record: $0) }
            self.sharedTrips.append(self.acceptedSharedTrips)
            completion(true)
        }
    }
//
//    func fetchTripsSharedWithUser(completion: @escaping ([SharedTrip]) -> Void) {
//
//        guard let loggedInUser = UserController.shared.loggedInUser
//            else { completion([]) ; return }
//        var sharedTrips = [SharedTrip]()
//
//        // If the user has pending shared trips, fetch them.
//
//            let pendingPredicate = NSPredicate(format: "recordID IN %@", loggedInUser.pendingSharedTripsRefs)
//            let query = CKQuery(recordType: "Trip", predicate: NSPredicate(value: true))
//            CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
//                if let error = error {
//                    print("There was an error fetching the pending shared trips in \(#function): \(error)")
//                }
//
//                if let records = records {
//                    //                    let pendingSharedTrips = records.compac
//                }
//
//                //                let acceptedPredicate = NSPredicate(format: "recordID IN %@", acceptedSharedTripsRefs)
//            }
//
//
//        let query = CKQuery(recordType: "Trip", predicate: NSPredicate(value: true))
//        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
//            if let error = error {
//                ("Error fetching trips shared with user. Error: \(error)")
//            }
//
//            guard let records = records else { completion([]) ; return }
//
//            for record in records {
//                guard let sharedTrip = SharedTrip(record: record) else { completion([]) ; return }
//                sharedTrips.append(sharedTrip)
//            }
//            //            self.sharedTrips = sharedTrips
//
//            completion(sharedTrips)
//        }
//    }
    
    func fetchPlacesForSharedTrips(completion: @escaping (Bool) -> Void) {
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
    
    func fetchCreator(for sharedTrip: SharedTrip, completion: @escaping (User?) -> Void) {
        let predicate = NSPredicate(format: "recordID == %@", sharedTrip.creatorRef)
        let query = CKQuery(recordType: "User", predicate: predicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("There was an error obtaining a shared trip user in \(#function): \(error)")
                completion(nil)
                return
            }
            guard let records = records,
                let userRecord = records.first
                else { completion(nil) ; return }
            let user = User(ckRecord: userRecord)
            completion(user)
        }
    }
    
    func accept(sharedTrip: SharedTrip, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        sharedTrip.isAcceptedTrip = true
        guard let loggedInUser = UserController.shared.loggedInUser,
           let indexToRemove = pendingSharedTrips.index(of: sharedTrip) else { completion(false) ; return }
    
        loggedInUser.pendingSharedTripsRefs.remove(at: indexToRemove)
        loggedInUser.pendingSharedTripsRefs.forEach { print($0.recordID.recordName) }
        let acceptedSharedRef = CKReference(recordID: sharedTrip.cloudKitRecordID!, action: .deleteSelf)
        loggedInUser.acceptedSharedTripsRefs.append(acceptedSharedRef)
        
        guard let record = CKRecord(user: loggedInUser) else { completion(false) ; return }
        CloudKitManager.shared.updateOperation(records: [record]) { (success) in
            if success {
                
                self.pendingSharedTrips.remove(at: indexToRemove)
                self.acceptedSharedTrips.append(sharedTrip)
                
                self.sharedTrips.removeAll()
                self.sharedTrips.append(self.pendingSharedTrips)
                self.sharedTrips.append(self.acceptedSharedTrips)
                
                completion(true)
            }
        }
    }
    
    func deny(sharedTrip: SharedTrip, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = UserController.shared.loggedInUser,
            let indexToRemove = pendingSharedTrips.index(of: sharedTrip) else { completion(false) ; return }
        
        loggedInUser.pendingSharedTripsRefs.remove(at: indexToRemove)
        
        guard let record = CKRecord(user: loggedInUser) else { completion(false) ; return }
        CloudKitManager.shared.updateOperation(records: [record]) { (success) in
            self.pendingSharedTrips.remove(at: indexToRemove)
            
            self.sharedTrips.removeAll()
            self.sharedTrips.append(self.pendingSharedTrips)
            self.sharedTrips.append(self.acceptedSharedTrips)
            
            completion(true)
        }
    }
}
