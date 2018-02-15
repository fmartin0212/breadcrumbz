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
    
    var sharedIDs = [String]()
    
    func addSharedIDTo(trip: Trip, forUser: User) {
        guard let userRecordID = forUser.ckRecordID else { return }
        let recordID = UsersSharedWithRecordIDs(recordID: userRecordID.recordName, trip: trip)
        saveToPersistentStore()
        guard let updatedTripRecord = CKRecord(trip: trip) else { return }
        CloudKitManager.shared.updateOperation(records: [updatedTripRecord]) { (success) in
            
        }
    }
 
    
    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.context.save()
        } catch let error {
            print("Error saving Managed Object Context (sharedIDs): \(error)")
        }
    }
}
