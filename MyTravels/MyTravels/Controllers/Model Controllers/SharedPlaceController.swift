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

        return placesDictionary.compactMap({ (_, value) -> SharedPlace? in
//            dispatchGroup.enter()
            
            guard let sharedPlace = SharedPlace(dictionary: value) else { return nil }
//            let storeRef = FirebaseManager.storeRef.child("Trips").child(placesDictionary.keys.first!).child("Places").child(sharedPlace.name!)
//            FirebaseManager.fetchImage(storeRef: storeRef, completion: { (image) in
//                if let image = image {
//                sharedPlace.photos = [image]
//                }
//            })
            return sharedPlace
        })
    }
}
