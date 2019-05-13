//
//  CheckIfBlockedOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/12/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class CheckIfBlockedOp: GroupOperation {
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
        super.init()
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

class CheckIfLoggedInUserBlockedOp: PSOperation {
    
    let receiver: InternalUser?
    let context: SaveTripContext
    
    init(receiver: InternalUser?, context: SaveTripContext) {
        self.receiver = receiver
        self.context = context
        super.init()
    }
    
    override func execute() {
        guard context.error != nil,
            let receiver = receiver,
            let receiversBlockedUIDs = receiver.blockedUserIDs,
            receiversBlockedUIDs.count != 0,
            let loggedInUser = InternalUserController.shared.loggedInUser,
            let loggedInUserUID = loggedInUser.uuid
            else { finish() ; return }
        if receiversBlockedUIDs.contains(loggedInUserUID) {
            context.error = .loggedInUserBlocked
            finish()
        } else {
            finish()
        }
    }
}
