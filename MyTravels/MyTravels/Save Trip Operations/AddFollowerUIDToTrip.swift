//
//  AddFollowerIDToTrip.swift
//  MyTravels
//
//  Created by Frank Martin on 5/12/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class AddFollowerUIDToTripOp: PSOperation {
    
    let trip: Trip
    let context: SaveTripContext
    
    init(trip: Trip, context: SaveTripContext) {
        self.trip = trip
        self.context = context
        super.init()
    }
    
    override func execute() {
        guard context.error == nil,
            let receiver = context.receiver,
            let receiverUID = receiver.uuid
            else { finish() ; return }
        context.firestoreService.update(object: trip, fieldsAndCriteria: ["followerUIDs" : [receiverUID]], with: .arrayAddition) { [weak self] (result) in
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
