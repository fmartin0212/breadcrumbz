//
//  UserController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static var shared = UserController()
    
    var loggedInUser: User?
    
    func createNewUserWith(username: String, firstName: String?, lastName: String?, phoneNumber: String?, profilePicture: Data?, completion: @escaping (Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("There was an error fetching the user's record ID. Error: \(error)")
                completion(false)
                return
            }
            guard let recordID = recordID else { completion(false) ; return }
            
            let appleUserRef = CKReference(recordID: recordID, action: .none)
            
            let newUser = User(username: username, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, profilePicture: profilePicture, appleUserRef: appleUserRef)
            
            guard let ckRecord = CKRecord(user: newUser) else { completion(false) ; return }
            
            CloudKitManager.shared.saveToCloudKit(ckRecord: ckRecord) { (success) in
                completion(true)
                self.loggedInUser = newUser
            }
        }
        
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserID, error) in
            if let error = error {
                print("No record ID found. \(error)")
                completion(false)
                return
            }
            
            guard let appleUserID = appleUserID else { completion(false) ; return }
            let predicate = NSPredicate(format: "appleUserRef == %@", appleUserID)
            let query = CKQuery(recordType: "User", predicate: predicate)
            CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("No records return. Error: \(error)")
                    self.loggedInUser = nil
                    completion(false)
                    return
                }
                guard let records = records,
                    let loggedInUserRecord = records.first,
                    let loggedInUser = User(ckRecord: loggedInUserRecord)
                    else { completion(false) ; return }
                
                self.loggedInUser = loggedInUser
                completion(true)
            })
        }
    }
}
