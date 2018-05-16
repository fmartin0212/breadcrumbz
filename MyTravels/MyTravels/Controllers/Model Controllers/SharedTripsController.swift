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
    var sharedTrips = [SharedTrip]()
    
    var sharedIDs = [String]()
    
    func addSharedIDTo(trip: Trip, forUser: User) {
        guard let userRecordID = forUser.ckRecordID else { return }
        let recordID = UsersSharedWithRecordIDs(recordID: userRecordID.recordName, isSynced: false, trip: trip)
        CoreDataManager.save()
        
        guard let updatedTripRecord = CKRecord(trip: trip) else { return }
        CloudKitManager.shared.updateOperation(records: [updatedTripRecord]) { (success) in
        }
    }
    
    func fetchTripsSharedWithUser(completion: @escaping ([SharedTrip]) -> Void) {
       
        guard let loggedInUser = UserController.shared.loggedInUser,
            let loggedInUserCKRecordID = loggedInUser.ckRecordID?.recordName
            else { completion([]) ; return }
        var sharedTrips = [SharedTrip]()
        guard let pendingSharedTripRefs = loggedInUser.pendingSharedTripsRefs else { completion([]) ; return }
        let predicate = NSPredicate(format: "recordID IN %@", pendingSharedTripRefs)
        let query = CKQuery(recordType: "Trip", predicate: predicate)
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                ("Error fetching trips shared with user. Error: \(error)")
            }
            
            guard let records = records else { completion([]) ; return }
            for record in records {
                guard let trip = SharedTrip(record: record) else { completion([]) ; return }
                sharedTrips.append(trip)
            }
            self.sharedTrips = sharedTrips
            
            completion(sharedTrips)
        }
    }
    
    func fetchPlacesForSharedTrips(sharedTrips: [SharedTrip], completion: @escaping (Bool) -> (Void)) {
        for sharedTrip in sharedTrips {
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
        completion(true)
    }
}
