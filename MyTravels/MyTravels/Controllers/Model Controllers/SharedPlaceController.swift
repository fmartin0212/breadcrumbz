//
//  SharedPlaceController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 10/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase

class SharedPlaceController {
    
    static func parsePlacesFrom(tripDictionary: [String : Any]) -> [SharedPlace]? {
        guard let placesDictionary = tripDictionary["places"] as? [String : [String : Any]]
            else { return nil }
        return placesDictionary.compactMap({ (key, value) -> SharedPlace? in
            guard let sharedPlace = SharedPlace(dictionary: value) else { return nil }
            return sharedPlace
        })
    }
}
