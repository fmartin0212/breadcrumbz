//
//  LocalPlace.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedPlace: FirebaseDBRetrievable, FirestoreRetrievable, CrumbObject {
    internal static var collectionName: String = "Crumb"
    
    var address: String
    var comments: String?
    var name: String
    var rating: Int16
    var typeString: String
    var type: Place.types? {
        return Place.types(rawValue: typeString)
    }
    var photoUIDs: [String]?
    let tripID: String
    
    required init?(dictionary: [String : Any], uuid: String) {
        guard let name = dictionary["name"] as? String,
            let address = dictionary["address"] as? String,
            let rating = dictionary["rating"] as? Int16,
            let typeString = dictionary["type"] as? String,
            let comments = dictionary["comments"] as? String,
            let tripID = dictionary["tripUID"] as? String
            else { return nil }
        
        if let photoUIDs = dictionary["photoUIDs"] as? [String] {
            self.photoUIDs = photoUIDs
        }
        
        self.name = name
        self.address = address
        self.rating = rating
        self.typeString = typeString
        self.comments = comments
        self.tripID = tripID
        self.uuid = uuid
    }
    
    var uuid: String?
    
    static var referenceName: String {
        return "Crumb"
    }
}
