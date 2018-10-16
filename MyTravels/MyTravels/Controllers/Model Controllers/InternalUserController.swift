//
//  UserController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class InternalUserController {
    
    static var shared = InternalUserController()
    
    var loggedInUser: InternalUser?
    
    func createNewUserWith(firstName: String, lastName: String?, username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        let newUser = InternalUser(firstName: firstName, lastName: lastName, username: username, email: email)
        FirebaseManager.addUser(with: email, password: password, username: username) { (firebaseUser, error) in
            if let error = error {
                // FIXME - Should switch on an enum
                print("Error saving a new user to the Firebase Database: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let firebaseUser = firebaseUser else { completion(false) ; return }
//            newUser.uid = firebaseUser.uid
            self.loggedInUser = newUser
            
            let internalUserDict: [String : Any] = [ "username" : newUser.username,
                            "email" : newUser.email,
                            "firstName" : newUser.firstName,
                            "lastName" : newUser.lastName ?? ""
                            ]
            
            let ref = FirebaseManager.ref.child("User").child(username)
            FirebaseManager.save(object: internalUserDict, to: ref, completion: { (error) in
                if let error = error {
                    // Present alert controller?
                } else {
                    completion(true)
                }
            })
        }
    }
    
    func checkForLoggedInUser(completion: @escaping (Bool) -> Void) {
        if let firebaseUser = FirebaseManager.getLoggedInUser() {
            let ref = FirebaseManager.ref.child("User").child(firebaseUser.displayName!)
            FirebaseManager.fetch(from: ref) { (snapshot) in
                let loggedInUser = InternalUser(snapshot: snapshot)
                self.loggedInUser = loggedInUser
                completion(true)
                return
            }
        } else {
            completion(false)
        }
    }
}
