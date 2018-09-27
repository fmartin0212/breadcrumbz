//
//  CloudKitManager.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

class CloudKitManager {
    
    static var shared = CloudKitManager()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // CRUD Functions
    // Add
    func saveToCloudKit(ckRecord: CKRecord, completion: @escaping (Bool) -> Void) {
        
        publicDB.save(ckRecord) { (record, error) in
            if let error = error {
                print("There was an error saving to the database: \(error)")
            } else {
                print("Save successful!")
                completion(true)
            }
        }
    }
    
    func performFullSync(completion: @escaping (Bool) -> Void) {
   
    }
    
    func pushPlacesToCloudKit(completion: @escaping (Bool) -> Void) {
    
    }

    func saveOperation(records: [CKRecord], completion: @escaping (Bool) -> Void) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyOperation.perRecordCompletionBlock = nil
        modifyOperation.savePolicy = .allKeys
        modifyOperation.queuePriority = .high
        modifyOperation.qualityOfService = .userInteractive
        publicDB.add(modifyOperation)
        completion(true)
    }
    
    func updateOperation(records: [CKRecord], completion: @escaping (Bool) -> Void) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyOperation.perRecordCompletionBlock = nil
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.queuePriority = .high
        modifyOperation.qualityOfService = .userInteractive
        publicDB.add(modifyOperation)
        completion(true)
    }
    
    
    // Sharing
    func fetchTripShareReceiverWith(firstName: String, completion: @escaping (User?) -> Void) {
      
    }
}
