//
//  FirebaseSyncable.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/16/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol FirebaseRetrievable {
    
    var uuid: String? { get }
    static var referenceName: String { get }
    init?(dictionary: [String : Any], uuid: String)
}

extension FirebaseRetrievable {
    
    static var databaseRef: DatabaseReference {
        return FirebaseManager.ref.child(Self.referenceName)
    }
}

protocol FirebaseSavable {
    
    var uuid: String? { get }
    static var referenceName: String { get }
    var dictionary: [String : Any] { get }
    
}

extension FirebaseSavable {
        
    var databaseRef: DatabaseReference  {
            return FirebaseManager.ref.child(Self.referenceName)
    }
}
