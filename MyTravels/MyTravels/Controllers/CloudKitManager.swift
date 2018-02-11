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
    
}
