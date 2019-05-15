//
//  User.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InternalUser: FirebaseDBSavable, FirestoreSavable, FirestoreRetrievable, FirebaseDBRetrievable {
    internal static var collectionName: String = "User"
    
    let firstName: String
    let lastName: String?
    let username: String
    let email: String
    var photoURL: String?
    var photo: UIImage?
    var tripsFollowingUIDs: [String]?
    var blockedUserIDs: [String]?
    var sharedTripIDs: [String]?
    
    // MARK: - Firebase Retrievable
    var uuid: String?
    static var referenceName: String = Constants.user
    
    // MARK: - Firebase Savable
    var dictionary: [String : Any] {
        return ["username" : self.username,
                "email" : self.email,
                "firstName" : self.firstName,
                "lastName" : self.lastName ?? ""
        ]
    }
    
    init(firstName: String, lastName: String?, username: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
    }
    
    
    required init?(dictionary: [String : Any], uuid: String) {
        
        guard let firstName = dictionary["firstName"] as? String,
            let username = dictionary["username"] as? String,
            let email = dictionary["email"] as? String
            else { return nil }
        
        self.firstName = firstName
        self.lastName = ""
        self.username = username
        self.email = email
        self.uuid = uuid
        
        if let photoURL = dictionary["photoPath"] as? String {
            self.photoURL = photoURL
//            InternalUserController.shared.fetchProfilePhoto(from: photoURL) { (result   ) in
//                self.photo = photo
//                NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
//            }
        }
        
        if let tripsFollowingUIDs = dictionary["tripsFollowingUIDs"] as? [String] {
            self.tripsFollowingUIDs = tripsFollowingUIDs.compactMap { $0 }
        }
        
        if let blockedUserIDs = dictionary["blockedUserIDs"] as? [String] {
            self.blockedUserIDs = blockedUserIDs.compactMap { $0 }
        }
        
        if let sharedTripIDs = dictionary["sharedTripIDs"] as? [String] {
            self.sharedTripIDs = sharedTripIDs.compactMap { $0 }
        }
    }
    
    // FIXME: - REMOVE/REFACTOR
    // Turn snapshot into User
    init?(snapshot: DataSnapshot) {
        
        guard let tripDict = snapshot.value as? [String : Any],
            let firstName = tripDict["firstName"] as? String,
            let lastName = tripDict["lastName"] as? String?,
            let username = tripDict["username"] as? String,
            let email = tripDict["email"] as? String
            
            else { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        
        if let photoURL = tripDict["photoURL"] as? String {
            self.photoURL = photoURL
        }
        
        if let participantTripIDs = tripDict["tripsFollowingUIDs"] as? [String] {
            self.tripsFollowingUIDs = participantTripIDs.compactMap { $0 }
        }
        
        if let blockedUserIDs = tripDict["blockedUserIDs"] as? [String] {
            self.blockedUserIDs = blockedUserIDs.compactMap { $0}
        }
        
    }
}

