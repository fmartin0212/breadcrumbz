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

protocol FirebaseSyncable {
    var id: UUID? { get set }
}

class FirebaseManager {
    
    static var ref: DatabaseReference!
    
    init() {
        print("asf")
    }
    
    static func save(object: [String : Any], to path: String) {
       ref = Database.database().reference()
        ref.setValue(object)
    }
}
