//
//  SaveTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class ShareTripOperation: GroupOperation {
    
    init(trip: Trip, service: FirestoreServiceProtocol, receiverUsername: String, completion: @escaping (Result<Bool, FireError>) -> Void) {
        let context = SaveTripContext(trip: trip, service: service)
        let checkIfBlockedOp = CheckIfBlockedOp(receiverUsername: receiverUsername, context: context)
        let addTripIDToReceiverOp = AddTripIDToReceiverOp(context: context)
        let addFollowerUIDToTripOp = AddFollowerUIDToTripOp(trip: trip, context: context)
        let taskCompleteOp = TaskCompleteOp(context: context, completion: completion)
        addTripIDToReceiverOp.addDependency(checkIfBlockedOp)
        addFollowerUIDToTripOp.addDependency(checkIfBlockedOp)
        taskCompleteOp.addDependency(addTripIDToReceiverOp)
        taskCompleteOp.addDependency(addFollowerUIDToTripOp)
        
        super.init(operations: [checkIfBlockedOp, addTripIDToReceiverOp, addFollowerUIDToTripOp, taskCompleteOp])
    }
}

class SaveTripOperation: GroupOperation {
    
    init(trip: Trip, receiverUsername: String, service: FirestoreServiceProtocol, completion: @escaping (Result<Bool, FireError>) -> Void) {
        let context = SaveTripContext(trip: trip, service: service)
        let checkIfBlockedOp = CheckIfBlockedOp(receiverUsername: receiverUsername, context: context)
        let uploadTrip = UploadTripOperation(context: context)
        let saveTripToCD = SaveCoreDataOperation()
        let addTripIDToReceiverOp = AddTripIDToReceiverOp(context: context)
        let addFollowerUIDToTripOp = AddFollowerUIDToTripOp(trip: trip, context: context)
        let updateUserOp = UpdateUserOperation(trip: trip, context: context)
        let uploadPlacesOp = UploadPlacesOperation(for: trip, with: context)
        let addCrumbIDsToTripOp = AddCrumbUIDsToTrip(trip, context: context)
        let updateReceiverOp = UpdateReceiverOp(receiverUsername: receiverUsername, context: context)
        let taskCompleteOp = TaskCompleteOp(context: context, completion: completion)
        uploadTrip.addDependency(checkIfBlockedOp)
        saveTripToCD.addDependency(uploadTrip)
        uploadPlacesOp.addDependency(uploadTrip)
        updateUserOp.addDependency(uploadTrip)
        addTripIDToReceiverOp.addDependency(uploadTrip)
        addCrumbIDsToTripOp.addDependency(uploadPlacesOp)
        addFollowerUIDToTripOp.addDependency(uploadTrip)
        taskCompleteOp.addDependency(addFollowerUIDToTripOp)
        taskCompleteOp.addDependency(uploadPlacesOp)
        
        super.init(operations: [checkIfBlockedOp, uploadTrip, saveTripToCD, addTripIDToReceiverOp, uploadPlacesOp, updateUserOp, addFollowerUIDToTripOp, addCrumbIDsToTripOp, updateReceiverOp, taskCompleteOp])
    }
}

class UploadTripOperation: PSOperation {
    
    let context: SaveTripContext
    
    init(context: SaveTripContext) {
        self.context = context
        super.init()
    }
    
    override func execute() {
        guard context.error == nil else {
            finish()
            return
        }
        
        context.service.save(object: context.trip) { result in
            switch result {
                case .success(let uuid):
                    self.context.trip.uuid = uuid
                    self.context.trip.uid = uuid
                case .failure(let error):
                    self.context.error = error
            }
            self.finish()
        }
    }
}
