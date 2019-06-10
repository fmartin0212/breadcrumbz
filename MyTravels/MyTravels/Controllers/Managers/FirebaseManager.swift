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
    
    static func save<T: FirebaseDBSavable>(_ object: T,
                                         uuid: String? = nil,
                                         completion: @escaping (_ errorMessage: String?, _ uuid: String?) -> Void) {
        
        var databaseRef = T.databaseRef
        
        // Used for Auth
        if let uuid = uuid {
            databaseRef = T.databaseRef.child(uuid)
        } else {
            databaseRef = T.databaseRef.childByAutoId()
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
    
    static func update<T: FirebaseDBSavable>(_ object: T,
                                           atChildren children: [String]? = nil,
                                           withValues values: [String : Any],
                                           completion: @escaping (String?) -> Void) {
        
        var databaseRef = T.databaseRef.child(object.uuid!)
        
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
    
    static func overwrite<T: FirebaseDBSavable>(_ object: T,
                                             atChildren children: [String]? = nil,
                                             withValues values: [String : Any],
                                             completion: @escaping (String?) -> Void) {
        
        var databaseRef = T.databaseRef.child(object.uuid!)
        
        if let children = children {
            children.forEach { databaseRef = databaseRef.child($0) }
        }
        
        databaseRef.setValue(values) { (error, _) in
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
    
    static func fetch<T: FirebaseDBRetrievable>(uuid: String? = nil,
                                              atChildKey childKey: String? = nil,
                                              withQuery query: String? = nil,
                                              completion: @escaping (T?) -> Void) {
        var databaseRef = T.databaseRef
        
        if let uuid = uuid {
            databaseRef = databaseRef.child(uuid)
        }
        
        if let childKey = childKey,
            let query = query {
            databaseRef.queryOrdered(byChild: childKey).queryEqual(toValue: query) .observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists(),
                let topLevelDictionary = snapshot.value as? [String : [String : Any]],
                let uuid = topLevelDictionary.keys.first,
                let dictionary = topLevelDictionary.values.first
                    else { completion(nil) ; return }
                let object = T(dictionary: dictionary, uuid: uuid)
                completion(object)
            }
        } else {
            databaseRef.observeSingleEvent(of: .value) { (snapshot) in
                guard snapshot.exists(),
                    let dictionary = snapshot.value as? [String : Any]
                    else { completion(nil) ; return }
                
                let object = T(dictionary: dictionary, uuid: snapshot.key)
                completion(object)
            }
        }
    }
    
    static func save(_ object: Any,
                     to databaseReference: DatabaseReference,
                     atChildren children: [String]? = nil,
                     completion: @escaping (Error?) -> Void) {
        
        databaseReference.setValue(object) { (error, _) in
            if let error = error {
                print("There was an error saving an object to the database")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    static func removeObject(ref: DatabaseReference,
                             completion: @escaping (Error?) -> Void) {
        ref.removeValue { (error, _) in
            completion(error)
        }
    }
    
    static func fetchObject(from ref: DatabaseReference,
                            completion: @escaping (DataSnapshot) -> Void) {
        ref.observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot)
        }
    }
}

