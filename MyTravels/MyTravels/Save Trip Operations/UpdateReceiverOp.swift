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

class FetchReceiverOp: PSOperation {
    let receiverUsername: String
    let context: SaveTripContext
    
    init(receiverUsername: String, context: SaveTripContext) {
        self.receiverUsername = receiverUsername
        self.context = context
    }
    
    override func execute() {
        context.service.fetch(uuid: nil, field: "username", criteria: receiverUsername, queryType: .fieldEqual) { [weak self] (result: Result<[InternalUser], FireError>) in
            switch result {
            case .success(let receiverUserArray):
                guard let receiver = receiverUserArray.first else { self?.finish() ; return }
                self?.context.receiver = receiver
                self?.finish()
            case .failure(let error):
                self?.context.error = error
                self?.finish()
            }
        }
    }
}

class AddTripIDToReceiverOp: PSOperation {
    let context: SaveTripContext
    init(context: SaveTripContext) {
        self.context = context
    }
    
    override func execute() {
        guard let receiver = context.receiver,
        let tripUUID = context.trip.uuid
        else { finish() ; return }
        context.service.update(object: receiver, atField: "tripsFollowingUIDs", withCriteria: [tripUUID], with: .arrayAddtion) { [weak self] (result) in
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
