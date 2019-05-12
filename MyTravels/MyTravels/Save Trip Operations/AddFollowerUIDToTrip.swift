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
    }
    
    override func execute() {
        guard let receiver = context.receiver,
            let receiverUID = receiver.uuid
            else { finish() ; return }
        context.service.update(object: trip, atField: "followerUIDs", withCriteria: [receiverUID], with: .arrayAddtion) { [weak self] (result) in
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
