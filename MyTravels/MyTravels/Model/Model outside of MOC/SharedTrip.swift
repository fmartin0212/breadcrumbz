//
//  LocalTrip.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SharedTrip: FirebaseDBRetrievable {
    
    var uuid: String?
    
    static var referenceName: String {
        return "Trip"
    }
    
    let name: String
    let location: String
    let description: String?
    let startDate: Date
    let endDate: Date
    let creatorName: String
    let creatorUsername: String
    let creatorID: String
    var photoID: String?
    var photo: UIImage?
    var places: [SharedPlace] = []
    var isAcceptedTrip: Bool = true
    var placeIDs: [String] = []
    
    
    required init?(dictionary: [String : Any], uuid: String) {
        
        guard let name = dictionary["name"] as? String,
        let location = dictionary["location"] as? String,
        let description = dictionary["description"] as? String?,
        let startDate = dictionary["startDate"] as? TimeInterval,
        let endDate = dictionary["endDate"] as? TimeInterval,
        let creator = dictionary["creatorName"] as? String,
        let creatorUsername = dictionary["creatorUsername"] as? String,
        let creatorID = dictionary["creatorID"] as? String
        else { return nil }
        
        self.name = name
        self.location = location
        self.description = description
        self.startDate = Date(timeIntervalSince1970: startDate)
        self.endDate = Date(timeIntervalSince1970: endDate)
        self.creatorName = creator
        self.creatorUsername = creatorUsername
        self.creatorID = creatorID
        self.uuid = uuid
        
        if let photoIDDictionary = dictionary["photoID"] as? [String : Bool],
            let photoID = photoIDDictionary.keys.first {
            self.photoID = photoID
        }
        
        if let placeIDs = dictionary["placeIDs"] as? [String : Bool] {
            self.placeIDs = placeIDs.compactMap { $0.key }
        }
    }
    
    init?(snapshot: DataSnapshot) {
//        self.uid = snapshot.key
        
        guard let tripDictionary = snapshot.value as? [String : Any],
            let name = tripDictionary["name"] as? String,
            let location = tripDictionary["location"] as? String,
            let description = tripDictionary["description"] as? String?,
            let startDate = tripDictionary["startDate"] as? TimeInterval,
            let endDate = tripDictionary["endDate"] as? TimeInterval,
            let creator = tripDictionary["creatorName"] as? String,
            let creatorUsername = tripDictionary["creatorUsername"] as? String,
            let creatorID = tripDictionary["creatorID"] as? String
            else { return nil }
        
        self.name = name
        self.location = location
        self.description = description
        self.startDate = Date(timeIntervalSince1970: startDate)
        self.endDate = Date(timeIntervalSince1970: endDate)
        self.creatorName = creator
        self.creatorUsername = creatorUsername
        self.creatorID = creatorID
        
        if let photoIDDictionary = tripDictionary["photoID"] as? [String : Bool],
            let photoID = photoIDDictionary.keys.first {
            self.photoID = photoID
        }
        
        if let placeIDs = tripDictionary["placeIDs"] as? [String : Bool] {
            self.placeIDs = tripDictionary.compactMap { $0.key }
        }
        
        SharedPlaceController.parsePlacesFrom(tripDictionary: tripDictionary) { (places) in
            self.places = places
        }
    }
}

extension SharedTrip: Equatable {
    
    static func == (lhs: SharedTrip, rhs: SharedTrip) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
