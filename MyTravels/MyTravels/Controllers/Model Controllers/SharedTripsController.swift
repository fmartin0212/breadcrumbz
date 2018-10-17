//
//  SharedTripsController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/15/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class SharedTripsController {
    
    static var shared = SharedTripsController()
    var sharedTrips: [SharedTrip] = []
    var pendingSharedTrips = [SharedTrip]()
    var acceptedSharedTrips = [SharedTrip]()
    
    var sharedIDs = [String]()
    
    func fetchSharedTrips(completion: @escaping (Bool) -> Void) {
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { completion(false) ; return }
        let ref = FirebaseManager.ref.child("User").child(loggedInUser.username).child("participantTripIDs")
        FirebaseManager.fetch(from: ref) { (snapshot) in
            guard let participantTripIDDictionaries = snapshot.value as? [String : [String : String]] else { completion(false) ; return }
            
            let dispatchGroup = DispatchGroup()
            for (_, value) in participantTripIDDictionaries {
                dispatchGroup.enter()
                let ref = FirebaseManager.ref.child("Trip").child(value["tripID"]!)
                FirebaseManager.fetch(from: ref, completion: { (snapshot) in
                    if let sharedTrip = SharedTrip(snapshot: snapshot) {
                        self.sharedTrips.append(sharedTrip)
                    }
                })
                dispatchGroup.leave()
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(true)
            })
        }
    }
    
    func fetchUsersPendingSharedTrips(completion: @escaping (Bool) -> Void) { 
        
        }

    func fetchAcceptedSharedTrips(completion: @escaping (Bool) -> Void) {
     
    }
    
    func fetchPlacesForSharedTrips(completion: @escaping (Bool) -> Void) {
      
    }
    
    func accept(sharedTrip: SharedTrip, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
      
    }
    
    func deny(sharedTrip: SharedTrip, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
    }
}
