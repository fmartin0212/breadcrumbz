//
//  AddCrumbIDsToTrip.swift
//  MyTravels
//
//  Created by Frank Martin on 5/9/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class AddCrumbIDsToTrip: PSOperation {
    let trip: Trip
    let firestoreService: FirestoreServiceProtocol
    let context: SaveTripContext
    
    init(_ trip: Trip, context: SaveTripContext) {
        self.trip = trip
        self.context = context
        self.firestoreService = context.service
    }
    
    override func execute() {
        guard context.placeUIDs.count > 0 else { finish() ; return }
        firestoreService.update(object: trip, atField: "crumbIDs", withCriteria: context.placeUIDs, with: .arrayAddtion) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.finish()
            case .failure(let error):
                self?.context.error = error
                self?.finish()
            }
        }
    }
}
