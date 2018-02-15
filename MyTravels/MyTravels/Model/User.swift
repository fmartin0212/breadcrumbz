//
//  User.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    let username: String
    let password: String?
    let firstName: String?
    let lastName: String?
    let profilePicture: Data?
    var ckRecordID: CKRecordID?
    let appleUserRef: CKReference
    var sharedWithUserTripsRefs: [CKReference]?
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        try? profilePicture?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    init(username: String, password: String?, firstName: String?, lastName: String?, profilePicture: Data?, appleUserRef: CKReference, sharedWithUserTripsRefs: [CKReference]?) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.password = password
        self.profilePicture = profilePicture
        self.appleUserRef = appleUserRef
        self.sharedWithUserTripsRefs = sharedWithUserTripsRefs
    }
    
    // Turn record into User
    init?(ckRecord: CKRecord) {
        guard let username = ckRecord["username"] as? String,
            let password = ckRecord["password"] as? String,
            let firstName = ckRecord["firstName"] as? String,
            let lastName = ckRecord["lastName"] as? String,
            let profilePicture = ckRecord["profilePictureAsset"] as? CKAsset,
            let appleUserRef = ckRecord["appleUserRef"] as? CKReference,
            var sharedWithUserTripsRefs = ckRecord["sharedWithUserTripsRefs"] as? [CKReference]
        
            else { return nil }
        
        let photoData = try? Data(contentsOf: profilePicture.fileURL)
        
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.profilePicture = photoData
        self.appleUserRef = appleUserRef
        self.sharedWithUserTripsRefs = sharedWithUserTripsRefs
        
    }
}

// Turn User into a CKRecord
extension CKRecord {
 
    convenience init?(user: User) {
        
        let recordID = user.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let profilePictureAsset = CKAsset(fileURL: user.temporaryPhotoURL)
        
        self.init(recordType: "User", recordID: recordID)
        
        self.setValue(user.username, forKey: "username")
        self.setValue(user.password, forKey: "password")
        self.setValue(user.firstName, forKey: "firstName")
        self.setValue(user.lastName, forKey: "lastName")
        self.setValue(profilePictureAsset, forKey: "profilePictureAsset")
        self.setValue(user.appleUserRef, forKey: "appleUserRef")
        self.setValue(user.sharedWithUserTripsRefs, forKey: "sharedWithUserTripsRefs")
        
    }
    
}
