//
//  FirebaseSyncable.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/16/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol FirebaseSyncable {
    var uuid: String? { get set }
    static var referenceName: String { get }
}

extension FirebaseSyncable {
    static var databaseRef: DatabaseReference {
        return FirebaseManager.ref.child(Self.referenceName)
    }
}

protocol FirebaseDBRetrievable: FirebaseSyncable {
    init?(dictionary: [String : Any], uuid: String)
}

protocol FirebaseDBSavable: FirebaseSyncable {
    var dictionary: [String : Any] { get }
}

protocol FirebaseStorageSavable {
    var data: Data { get }
    var uid: String { get }
}
