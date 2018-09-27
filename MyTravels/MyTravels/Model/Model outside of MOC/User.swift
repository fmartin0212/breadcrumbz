//
//  User.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User {
    
    let firstName: String?
    let lastName: String?
    let username: String?
    var profilePicture: Data?
    var uid: String?
    
    init(firstName: String?, lastName: String?, username: String?, profilePicture: Data?) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.profilePicture = profilePicture
    }
    
    // Turn record into User
    init?(snapshot: DataSnapshot) {
        
        guard let tripDict = snapshot.value as? [String : Any],
            let firstName = tripDict["firstName"] as? String,
            let lastName = tripDict["lastName"] as? String,
            let username = tripDict["username"] as? String
            //FIXME profle pic
            else { return nil }
        
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        // FIX ME
        //        self.profilePicture = photoData
        // FIX ME - Set UID
    }
}
