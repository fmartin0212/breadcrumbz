//
//  LocalTrip.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SharedTrip {
    
    let name: String
    let location: String
    let tripDescription: String?
    let startDate: Date
    let endDate: Date
    let creatorName: String
    let creatorUsername: String
    var photo: UIImage?
    var places: [SharedPlace] = []
    var isAcceptedTrip: Bool = true
    
    var uid: String
    
    init?(snapshot: DataSnapshot) {
        self.uid = snapshot.key
        
        guard let tripDictionary = snapshot.value as? [String : Any],
            let name = tripDictionary["name"] as? String,
            let location = tripDictionary["location"] as? String,
            let tripDescription = tripDictionary["tripDescription"] as? String?,
            let startDate = tripDictionary["startDate"] as? TimeInterval,
            let endDate = tripDictionary["endDate"] as? TimeInterval,
            let creator = tripDictionary["creatorName"] as? String,
            let creatorUsername = tripDictionary["creatorUsername"] as? String
            else { return nil }
        
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = Date(timeIntervalSince1970: startDate)
        self.endDate = Date(timeIntervalSince1970: endDate)
        self.creatorName = creator
        self.creatorUsername = creatorUsername
        
        SharedPlaceController.parsePlacesFrom(tripDictionary: tripDictionary) { (places) in
            self.places = places
        }
    }
}

extension SharedTrip: Equatable {
    static func == (lhs: SharedTrip, rhs: SharedTrip) -> Bool {
        return lhs.uid == rhs.uid
    }
}
