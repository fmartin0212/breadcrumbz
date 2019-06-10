//
//  LocalTrip.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SharedTrip: FirebaseDBRetrievable, FirestoreRetrievable, TripObject {
    internal static var collectionName: String = "Trip"
    var uuid: String?
    static var referenceName: String {
        return "Trip"
    }
    var name: String
    var location: String
    var tripDescription: String?
    var startDate: NSDate
    var endDate: NSDate
    let creatorName: String
    let creatorUsername: String
    let creatorID: String
    var photoUID: String?
    var photo: UIImage?
    var places: [SharedPlace] = []
    var isAcceptedTrip: Bool = true
    var placeIDs: [String] = []
    var crumbCount: Int {
        return self.placeIDs.count
    }
    
    
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
        self.tripDescription = description
        self.startDate = Date(timeIntervalSince1970: startDate) as NSDate
        self.endDate = Date(timeIntervalSince1970: endDate) as NSDate
        self.creatorName = creator
        self.creatorUsername = creatorUsername
        self.creatorID = creatorID
        self.uuid = uuid
        
        photoUID = dictionary["photoUID"] as? String
        
        if let placeIDs = dictionary["crumbUIDs"] as? [String] {
            self.placeIDs = placeIDs
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
        self.tripDescription = description
        self.startDate = Date(timeIntervalSince1970: startDate) as NSDate
        self.endDate = Date(timeIntervalSince1970: endDate) as NSDate
        self.creatorName = creator
        self.creatorUsername = creatorUsername
        self.creatorID = creatorID
        
        if let photoUID = tripDictionary["photoUID"] as? String {
            self.photoUID = photoUID
        }
        
        if let placeIDs = tripDictionary["placeIDs"] as? [String] {
            self.placeIDs = placeIDs
        }
        
//        SharedPlaceController.parsePlacesFrom(tripDictionary: tripDictionary) { (places) in
//            self.places = places
//        }
    }
}

extension SharedTrip: Equatable {
    
    static func == (lhs: SharedTrip, rhs: SharedTrip) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
