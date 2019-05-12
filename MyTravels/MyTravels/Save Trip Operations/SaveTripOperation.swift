//
//  SaveTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class SaveTripOperation: GroupOperation {
    
    init(trip: Trip, receiverUsername: String, service: FirestoreServiceProtocol, completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        let context = SaveTripContext(trip: trip, service: service)
        let saveTripToCD = SaveCoreDataOperation()
        let uploadTrip = UploadTripOperation(context: context)
        let updateUserOp = UpdateUserOperation(trip: trip, context: context)
        let uploadPlacesOp = UploadPlacesOperation(for: trip, with: context)
        let addCrumbIDsToTripOp = AddCrumbIDsToTrip(trip, context: context)
        let updateReceiverOp = UpdateReceiverOp(receiverUsername: receiverUsername, context: context)
        let doneOp = DidSaveTripOperation(context: context, completion: completion)
        saveTripToCD.addDependency(uploadTrip)
        uploadPlacesOp.addDependency(uploadTrip)
        updateUserOp.addDependency(uploadTrip)
        addCrumbIDsToTripOp.addDependency(uploadPlacesOp)
        updateReceiverOp.addDependency(uploadTrip)
        doneOp.addDependency(uploadPlacesOp)
        
        super.init(operations: [uploadTrip, saveTripToCD, uploadPlacesOp, updateUserOp, addCrumbIDsToTripOp, updateReceiverOp, doneOp])
    }
}

class UploadTripOperation: PSOperation {
    
    let context: SaveTripContext
    
    init(context: SaveTripContext) {
        self.context = context
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
