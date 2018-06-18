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
    
    let firstName: String?
    let lastName: String?
    let username: String?
    let profilePicture: Data?
    var ckRecordID: CKRecordID?
    let appleUserRef: CKReference
    var pendingSharedTripsRefs: [CKReference] = []
    var acceptedSharedTripsRefs: [CKReference] = []
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        try? profilePicture?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    init(firstName: String?, lastName: String?, username: String?, profilePicture: Data?, appleUserRef: CKReference) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.profilePicture = profilePicture
        self.appleUserRef = appleUserRef
    }
    
    // Turn record into User
    init?(ckRecord: CKRecord) {
        
        guard let firstName = ckRecord["firstName"] as? String,
            let lastName = ckRecord["lastName"] as? String,
            let username = ckRecord["username"] as? String,
            let profilePicture = ckRecord["profilePictureAsset"] as? CKAsset,
            let appleUserRef = ckRecord["appleUserRef"] as? CKReference
            else { return nil }
        
        if let pendingSharedTripsRefs = ckRecord["pendingSharedTrips"] as? [CKReference] {
            self.pendingSharedTripsRefs = pendingSharedTripsRefs
        }
        if let acceptedSharedTripsRefs = ckRecord["acceptedSharedTrips"] as? [CKReference] {
            self.acceptedSharedTripsRefs = acceptedSharedTripsRefs
        }
        
        let photoData = try? Data(contentsOf: profilePicture.fileURL)
        
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.profilePicture = photoData
        self.appleUserRef = appleUserRef
        self.ckRecordID = ckRecord.recordID
        }
    }

// Turn User into a CKRecord
extension CKRecord {
    
    convenience init?(user: User) {

        let recordID = user.ckRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let profilePictureAsset = CKAsset(fileURL: user.temporaryPhotoURL)
        
        self.init(recordType: "User", recordID: recordID)
        
        self.setValue(user.firstName, forKey: "firstName")
        self.setValue(user.lastName, forKey: "lastName")
        self.setValue(user.username, forKey: "username")
        self.setValue(profilePictureAsset, forKey: "profilePictureAsset")
        self.setValue(user.appleUserRef, forKey: "appleUserRef")
        self.setValue(user.pendingSharedTripsRefs, forKey: "pendingSharedTrips")
        self.setValue(user.acceptedSharedTripsRefs, forKey: "acceptedSharedTrips")
    }
}
