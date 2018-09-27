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
    var sharedTrips: [[SharedTrip]] = []
    var pendingSharedTrips = [SharedTrip]()
    var acceptedSharedTrips = [SharedTrip]()
    
    var sharedIDs = [String]()
    
    
    func addSharedIDTo(trip: Trip, forUser: User) {
      
    }
    
    func fetchUsersPendingSharedTrips(completion: @escaping (Bool) -> Void) {
    
        }

    func fetchAcceptedSharedTrips(completion: @escaping (Bool) -> Void) {
     
    }
    
    func fetchPlacesForSharedTrips(completion: @escaping (Bool) -> Void) {
      
    }
    
    func fetchCreator(for sharedTrip: SharedTrip, completion: @escaping (User?) -> Void) {
       
    }
    
    func accept(sharedTrip: SharedTrip, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
      
    }
    
    func deny(sharedTrip: SharedTrip, at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
    }
}
