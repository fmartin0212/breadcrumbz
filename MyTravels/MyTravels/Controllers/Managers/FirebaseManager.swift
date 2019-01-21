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
import FirebaseAuth

final class FirebaseManager {
    
    // MARK: - Constants & Variables
    
    static var ref: DatabaseReference! = Database.database().reference()
    static var storeRef: StorageReference! = Storage.storage().reference()
    
    // MARK: - Database
    
    static func save<T: FirebaseSavable>(_ object: T,
                                         uuid: String? = nil,
                                         completion: @escaping (_ errorMessage: String?, _ uuid: String?) -> Void) {
        
        var databaseRef = object.databaseRef
        
        // Used for Auth
        if let uuid = uuid {
            databaseRef = databaseRef.child(uuid)
        } else {
            databaseRef = object.databaseRef.childByAutoId()
        }
    
        databaseRef.setValue(object.dictionary) { (error, databaseRef) in
            if let _ = error {
                print("There was an error saving an object to the database")
                completion(Constants.somethingWentWrong, nil)
                return
            } else {
                completion(nil, databaseRef.key)
            }
        }
    }
    
    static func update<T: FirebaseSavable>(_ object: T,
                                           atChildren children: [String]? = nil,
                                           withValues values: [String : Any],
                                           completion: @escaping (String?) -> Void) {
        
        var databaseRef = object.databaseRef.child(object.uuid!)
        
        if let children = children {
            children.forEach { databaseRef = databaseRef.child($0) }
        }
        
        databaseRef.updateChildValues(values) { (error, _) in
            if let error = error {
                print(error)
                completion(Constants.somethingWentWrong)
                return
            }
            completion(nil)
        }
    }
    
    static func updateObject(at ref: DatabaseReference, value: [String : Any], completion: @escaping (_ errorMessage: String?) -> Void) {
        ref.updateChildValues(value) { (error, _) in
            if let _ = error {
                completion(Constants.somethingWentWrong)
                return
            }
            completion(nil)
        }
    }
    
    static func fetch<T: FirebaseRetrievable>(uuid: String? = nil,
                                              atChildren children: [String]? = nil,
                                              withQuery query: String? = nil,
                                              completion: @escaping (T?) -> Void) {
        var databaseRef = T.databaseRef
        
        if let uuid = uuid {
            databaseRef = databaseRef.child(uuid)
        }
        
        if let query = query {
            databaseRef.queryEqual(toValue: query)
        }
        
        if let children = children {
            children.forEach { databaseRef = databaseRef.child($0) }
        }
        
        databaseRef.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists(),
                let dictionary = snapshot.value as? [String : Any]
                else { completion(nil) ; return }
            
            let object = T(dictionary: dictionary, uuid: snapshot.key)
            completion(object)
        }
    }
    
    static func save(_ object: Any, to databaseReference: DatabaseReference, atChildren children: [String]? = nil, completion: @escaping (Error?) -> Void) {
        
        databaseReference.setValue(object) { (error, _) in
            if let error = error {
                print("There was an error saving an object to the database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    static func removeObject(ref: DatabaseReference, completion: @escaping (Error?) -> Void) {
        ref.removeValue { (error, _) in
            completion(error)
        }
    }
    
    static func fetchObject(from ref: DatabaseReference, completion: @escaping (DataSnapshot) -> Void) {
        ref.observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
    
    // MARK: - Auth
    
    static func addUser(with email: String, password: String, username: String, completion: @escaping (User?, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        completion(nil, Constants.emailInUse)
                    case .invalidEmail:
                        completion(nil, Constants.invalidEmail)
                    case .weakPassword:
                        completion(nil, Constants.weakPassword)
                    default:
                        completion(nil, Constants.somethingWentWrong)
                    }
                    print("There was an error creating a new user: \(error.localizedDescription)")
                    return
                }
            }
            
            guard let user = user else { completion(nil, Constants.somethingWentWrong) ; return }
            
            // Update displayName in Authentication storage
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username
            changeRequest.commitChanges(completion: { (error) in
                if let error = error {
                    print(error as Any)
                }
                completion(user, nil)
            })
        }
    }
    
    static func login(withEmail email: String, and password: String, completion: @escaping (User?, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (firebaseUser, error) in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode  {
                    case .wrongPassword:
                        completion(nil, Constants.wrongPassword)
                    case .invalidCredential:
                        completion(nil, Constants.noAccount)
                    case .userNotFound:
                        completion(nil, Constants.noAccount)
                    default:
                        completion(nil, Constants.somethingWentWrong)
                    }
                    return
                }
            } else {
                completion(firebaseUser, nil)
            }
        }
    }
    
    static func getLoggedInUser() -> User? {
        return Auth.auth().currentUser
    }
    
    static func logOutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    // MARK: - Storage
    
    static func save(data: Data,
                     to storeRef: StorageReference,
                     completion: @escaping (StorageMetadata?, Error?) -> Void) {
        
        storeRef.putData(data, metadata: nil) { (metadata, error) in
            completion(metadata, error)
        }
    }
    
    static func save<T: FirebaseStorageSavable>(_ object: T, completion: @escaping (StorageMetadata?, String?) -> Void) {
        let storageRef = Storage.storage().reference()

        storageRef.putData(object.data, metadata: nil) { (metadata, error) in
            if let _ = error {
                completion(nil, Constants.somethingWentWrong)
                return
            }
            
            if let metadata = metadata {
                
                completion(metadata, nil)
            }
        }
    }
    
    static func fetchImage(storeRef: StorageReference, completion: @escaping (UIImage?) -> Void) {
        storeRef.getData(maxSize: 9999999) { (data, error) in
            if let error = error {
                print("There was an error getting the image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            let image = UIImage(data: data)
            completion(image)
        }
    }
    
    static func performQuery(completion: @escaping (Bool) -> Void) {
        let ref = FirebaseManager.ref.child("User").queryEqual(toValue: "frank", childKey: "username")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children {
                print(child)
                print("dsaf")
            }
        }
    }
}


