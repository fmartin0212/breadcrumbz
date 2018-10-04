//
//  FirebaseManager.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 9/24/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseStorageUI
import FirebaseAuth

protocol FirebaseSyncable {
    var id: String? { get set }
}

class FirebaseManager {
    
    static var ref: DatabaseReference! = Database.database().reference()
    
    static func save(object: [String : Any], to databaseReference: DatabaseReference, completion: @escaping (Error?) -> Void) {
        databaseReference.setValue(object) { (error, _) in
            if let error = error {
                print("There was an error saving an object to the database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    static func addUser(with email: String, password: String, completion: @escaping (User?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                
                print("There was an error creating a new user: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            guard let user = user else { completion(nil, error) ; return }
            completion(user, nil)
        }
    }
    
    static func login(with email: String, and password: String, completion: @escaping (User?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (firebaseUser, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(firebaseUser, nil)
        }
    }
    
    static func checkForLoggedInUser() -> User? {
         return Auth.auth().currentUser
    }
    
    static func fetch(from ref: DatabaseReference, completion: @escaping (DataSnapshot) -> Void) {
        ref.observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
}
