//
//  UpdateReceiverOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/10/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateReceiverOp: GroupOperation {
    let receiverUsername: String
    let context: SaveTripContext
    
    init(receiverUsername: String, context: SaveTripContext) {
        self.receiverUsername = receiverUsername
        self.context = context
        
        let fetchReceiverOp = FetchReceiverOp(receiverUsername: receiverUsername, context: context)
        let addTripIDToReceiverOp = AddTripIDToReceiverOp(context: context)
        addTripIDToReceiverOp.addDependency(fetchReceiverOp)
        super.init(operations: [fetchReceiverOp, addTripIDToReceiverOp])
    }
}

class AddTripIDToReceiverOp: PSOperation {
    let context: SaveTripContext
    init(context: SaveTripContext) {
        self.context = context
        super.init()
    }
    
    override func execute() {
        guard let receiver = context.receiver,
        let tripUUID = context.trip.uuid
        else { finish() ; return }
        context.firestoreService.update(object: receiver, fieldsAndCriteria: ["tripsFollowingUIDs" : [tripUUID]], with: .arrayAddition) { [weak self] (result) in
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
