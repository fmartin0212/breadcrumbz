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
    let firestoreService: FirestoreServiceProtocol
    init() {
        self.firestoreService = FirestoreService()
    }
}

extension SharedTripsController {
    
    func fetchSharedTrips(completion: @escaping (Result<[SharedTrip], FireError>) -> Void) {
        guard let loggedInUser = InternalUserController.shared.loggedInUser,
            let participantTripIDs = loggedInUser.tripsFollowingUIDs,
            participantTripIDs.count > 0,
            let loggedInUserUUID = loggedInUser.uuid
            else { completion(.failure(.generic)) ; return }
        clearSharedTrips()
        
        firestoreService.fetch(uuid: nil, field: "followerUIDs", criteria: loggedInUserUUID, queryType: .fieldArrayContains) { (result: Result<[SharedTrip], FireError>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let sharedTrips):
                completion(.success(sharedTrips))
            }
        }
    }
    
    func clearSharedTrips() {
        sharedTrips = []
    }
}
