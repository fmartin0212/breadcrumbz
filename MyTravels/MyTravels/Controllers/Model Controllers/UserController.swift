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
    
    func createNewUserWith(firstName: String, lastName: String?, email: String, password: String, completion: @escaping (Bool) -> Void) {
        let newUser = InternalUser(firstName: firstName, lastName: lastName, email: email)
        FirebaseManager.addUser(with: email, password: password) { (firebaseUser, error) in
            if let error = error {
                // FIXME - Should switch on an enum
                print("Error saving a new user to the Firebase Database: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let firebaseUser = firebaseUser else { completion(false) ; return }
            newUser.uid = firebaseUser.uid
            self.loggedInUser = newUser
            
            let userDict: [String : Any] = ["email" : newUser.email,
                            "firstName" : newUser.firstName,
                            "lastName" : newUser.lastName ?? ""
                            ]
            
            let ref = FirebaseManager.ref.child(newUser.uid ?? "")
            FirebaseManager.save(object: userDict, to: ref)
            
            completion(true)
        }
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
        
    }
}
