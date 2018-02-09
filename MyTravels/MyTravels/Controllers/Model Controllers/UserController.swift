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
    
    func createNewUserWith(_ username: String, password: String, firstName: String?, lastName: String?, profilePicture: Data?, completion: @escaping (Bool) -> Void) {
        
        let newUser = User(username: username, password: password, firstName: firstName, lastName: lastName, profilePicture: profilePicture)
        
        guard let ckRecord = CKRecord(user: newUser) else { completion(false) ; return }
        
        CloudKitManager.shared.saveToCloudKit(ckRecord: ckRecord) { (success) in
            completion(true)
        }
    }
}
