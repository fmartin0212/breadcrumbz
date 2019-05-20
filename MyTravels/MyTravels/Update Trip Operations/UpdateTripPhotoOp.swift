//
//  UpdateTripPhotoOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateTripPhotoOp: GroupOperation {
    let context: UpdateTripContext
    
    init(context: UpdateTripContext) {
        self.context = context
        
        var operations: [PSOperation] = []
        if context.trip.photo == nil && context.image == nil {
            
        }
        if context.trip.photo?.image == context.image {
            
        } else if context.trip.photo == nil && context.image != nil {
            // The trip did not originally have a photo, and now it has one. We need to upload the new one and update the trip/core data
            let uploadTripPhotoGroupOp = UploadTripPhotoGroupOp(trip: context.trip, context: context)
            operations.append(uploadTripPhotoGroupOp)
        } else if context.trip.photo != nil && context.image == nil {
            // Originally, the trip contained a photo, but the user deleted the trip
            // Delete the current photo on firebase, update the trip's properties, then update the trips photoUID, and then update core data
            let deleteCurrentTripPhotoOp = DeleteCurrentTripPhotoOp(context: context)
            let removePhotoUIDFromTripOp = AddPhotoUIDToTripOp(context: context)
            
        }
        
        if context.trip.photo != nil && context.image == nil {
            // delete the trip photo from firebase and update the trip with the new photoUID
            // delete photo op
            // update trip op
            // save to core data op
        }
        if context.trip.photo == nil && context.image != nil {
            // upload the trip's photo, update the trip, update core data
        }
        super.init(operations: operations)
    }
}

class DeleteCurrentTripPhotoOp: PSOperation {
    
    var context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
    }
    
    override func execute() {
        guard let photo = context.trip.photo else { finish() ; return }
        context.firebaseStorageService.delete(object: photo) { [weak self] (result) in
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

class RemoveTripUID: PSOperation {
    
    let context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
    }
    
    override func execute() {
        context.firestoreService.update(object: context.trip, atField: <#T##String#>, withCriteria: <#T##[String]#>, with: <#T##FirestoreUpdateType#>, completion: <#T##(Result<Bool, FireError>) -> Void#>)
    }
}
