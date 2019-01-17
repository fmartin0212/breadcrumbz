//
//  FirebaseSyncable.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/16/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol FirebaseSyncable: class {
    
    var uuid: String { get }
    static var CollectionName: String { get }
    init?(dictionary: [String : Any], uuid: String)
}

