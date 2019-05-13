//
//  UpdateUserOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateUserOperation: PSOperation {
    
    let trip: Trip
    let firestoreService: FirestoreServiceProtocol
    let context: SaveTripContext
    
    init(trip: Trip, context: SaveTripContext) {
        self.trip = trip
        self.firestoreService = context.service
        self.context = context
        super.init()
    }

    override func execute() {
        guard let user = InternalUserController.shared.loggedInUser,
            let tripUUID = trip.uuid
            else { finish() ; return }
        firestoreService.update(object: user, atField: "sharedTripIDs", withCriteria: [tripUUID], with: .arrayAddtion) { [weak self] (result) in
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
