//
//  UploadTripPhotoOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/14/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UploadTripPhotoGroupOp: GroupOperation {
    
    init(trip: Trip, context: SaveTripContext) {
        if let photo = trip.photo {
            let saveTripPhotoOp = SavePhotoOperation(photo: photo, context: context)
            let addPhotoUIDToTripOp = AddPhotoUIDToTripOp(context: context)
            addPhotoUIDToTripOp.addDependency(saveTripPhotoOp)
            super.init(operations: [saveTripPhotoOp, addPhotoUIDToTripOp])
        } else {
            super.init(operations: [])
        }
    }
}

class AddPhotoUIDToTripOp: PSOperation {
    let context: SaveTripContext
    
    init(context: SaveTripContext) {
        self.context = context
        super.init()
    }
    
    override func execute() {
            guard let tripPhoto = context.trip.photo else { finish() ; return }
        context.service.update(object: context.trip, atField: "photoUID", withCriteria: [tripPhoto.uid], with: .update) { [weak self] (result) in
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


