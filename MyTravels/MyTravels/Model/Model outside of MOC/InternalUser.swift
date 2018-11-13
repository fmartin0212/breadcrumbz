//
//  User.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class InternalUser {
    
    let firstName: String
    let lastName: String?
    let username: String
    let email: String
    var photoURL: String?
    var photo: UIImage?
    var participantTripIDs: [String]?
    
    init(firstName: String, lastName: String?, username: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
    }
    
    // Turn snapshot into User
    init?(snapshot: DataSnapshot) {
        
        guard let tripDict = snapshot.value as? [String : Any],
            let firstName = tripDict["firstName"] as? String,
            let lastName = tripDict["lastName"] as? String?,
            let username = tripDict["username"] as? String,
            let email = tripDict["email"] as? String
            //FIXME profle pic
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
        
        if let participantTripIDDictionary = tripDict["participantTripIDs"] as? [String : Any] {
            self.participantTripIDs = participantTripIDDictionary.compactMap { $0.key }
            print("break")
            }
        }
    }

