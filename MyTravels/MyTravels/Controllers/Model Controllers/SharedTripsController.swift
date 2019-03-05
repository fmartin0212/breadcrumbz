//
//  SharedTripsController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/15/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

class SharedTripsController {
    
    // MARK: - Properties
    
    static var shared = SharedTripsController()
    var sharedTrips: [SharedTrip] = []
}

extension SharedTripsController {
    
    func fetchSharedTrips(completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = InternalUserController.shared.loggedInUser,
            let participantTripIDs = loggedInUser.participantTripIDs,
            participantTripIDs.count > 0
            else { completion(false) ; return }
        
        let dispatchGroup = DispatchGroup()
        for tripID in participantTripIDs {
            dispatchGroup.enter()
            
            let ref = FirebaseManager.ref.child("Trip").child(tripID)
            FirebaseManager.fetchObject(from: ref, completion: { (snapshot) in
                if let sharedTrip = SharedTrip(snapshot: snapshot) {
                    
                    self.sharedTrips.append(sharedTrip)
                    
                    dispatchGroup.enter()
                    let storeRef = FirebaseManager.storeRef.child("Trip").child(sharedTrip.uid)
                    FirebaseManager.fetchImage(storeRef: storeRef, completion: { (image) in
                        if let image = image {
                            sharedTrip.photo = image
                        }
                        dispatchGroup.leave()
                    })
                }
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main, execute: {
            //                self.sharedTrips = sharedTripsPlaceholder
            completion(true)
        })
    }
    
    func clearSharedTrips() {
        sharedTrips = []
    }
}
