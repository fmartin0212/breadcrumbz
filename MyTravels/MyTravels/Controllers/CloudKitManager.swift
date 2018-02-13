//
//  CloudKitManager.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    static var shared = CloudKitManager()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // CRUD Functions
    // Add
    func saveToCloudKit(ckRecord: CKRecord, completion: @escaping (Bool) -> Void) {
        
        publicDB.save(ckRecord) { (record, error) in
            if let error = error {
                print("There was an error saving to the database: \(error)")
            }

            else {
                print("Save successful!")
                completion(true)
                
            }
        }
        
    }
    
    // MARK: - Helper Fetches
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Trip":
            return TripController.shared.trips.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func syncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { !$0.isSynced }
    }

    
}
