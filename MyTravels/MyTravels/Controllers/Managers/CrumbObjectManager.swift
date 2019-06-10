//
//  CrumbObjectManager.swift
//  MyTravels
//
//  Created by Frank Martin on 5/15/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class CrumbObjectManager {
    
    let firestoreService: FirestoreServiceProtocol = FirestoreService()
    
    func fetchCrumbs(for trip: TripObject, completion: @escaping (Result<[CrumbObject], FireError>) -> Void) {
        if let trip = trip as? Trip {
            guard let crumbs = trip.places?.allObjects as? [Place] else { completion(.success([])) ; return }
            completion(.success(crumbs))
        } else {
            guard let sharedTrip = trip as? SharedTrip,
                let sharedTripUID = sharedTrip.uuid
                else { completion(.failure(.generic)) ; return }
            firestoreService.fetch(uuid: nil, field: "tripUID", criteria: sharedTripUID, queryType: .fieldEqual) { (result: Result<[SharedPlace], FireError>) in
                switch result {
                case .success(let crumbs):
                    completion(.success(crumbs))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
