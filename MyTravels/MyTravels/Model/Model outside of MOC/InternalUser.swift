//
//  User.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InternalUser: FirebaseSavable, FirebaseRetrievable {
    
    let firstName: String
    let lastName: String?
    let username: String
    let email: String
    var photoURL: String?
    var photo: UIImage?
    var participantTripIDs: [String]?
    var blockedUsernames: [String]?
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
            let lastName = dictionary["lastName"] as? String?,
            let username = dictionary["username"] as? String,
            let email = dictionary["email"] as? String
            else { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.uuid = uuid
        
        if let photoURL = dictionary["photoURL"] as? String {
            self.photoURL = photoURL
            InternalUserController.shared.fetchProfilePhoto(from: photoURL) { (photo) in
                guard let photo = photo else { return }
                self.photo = photo
                NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
            }
        }
        
        if let participantTripIDs = dictionary["participantTripIDs"] as? [String : Any] {
            self.participantTripIDs = participantTripIDs.compactMap { $0.key }
        }
        
        if let blockedUsernames = dictionary["blockedUsernames"] as? [String : Any] {
            self.blockedUsernames = blockedUsernames.compactMap { $0.key }
        }
        
        if let sharedTripIDs = dictionary["sharedTripIDs"] as? [String : Any] {
            self.sharedTripIDs = sharedTripIDs.compactMap { $0.key }
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
            InternalUserController.shared.fetchProfilePhoto(from: photoURL) { (photo) in
                guard let photo = photo else { return }
                self.photo = photo
                NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
            }
        }
        
        if let participantTripIDs = tripDict["participantTripIDs"] as? [String : Any] {
            self.participantTripIDs = participantTripIDs.compactMap { $0.key }
        }
        
        if let blockedUsernames = tripDict["blockedUsernames"] as? [String : Any] {
            self.blockedUsernames = blockedUsernames.compactMap { $0.key }
        }
        
    }
}

