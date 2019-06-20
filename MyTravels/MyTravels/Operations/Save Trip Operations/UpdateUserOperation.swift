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
        self.firestoreService = context.firestoreService
        self.context = context
        super.init()
    }

    override func execute() {
        guard context.error == nil,
            let user = InternalUserController.shared.loggedInUser,
            let tripUUID = trip.uuid,
            !user.sharedTripIDs.contains(tripUUID)
            else { finish() ; return }
        firestoreService.update(object: user, fieldsAndCriteria: ["sharedTripIDs" : [tripUUID]], with: .arrayAddition) { [weak self] (result) in
            switch result {
            case .success(_):
                InternalUserController.shared.loggedInUser?.sharedTripIDs.append(tripUUID)
                self?.finish()
            case .failure(let error):
                self?.context.error = error
                self?.finish()
            }
        }
    }
}
