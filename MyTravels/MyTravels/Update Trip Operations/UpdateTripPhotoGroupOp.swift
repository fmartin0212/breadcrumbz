//
//  UpdateTripPhotoOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateTripPhotoGroupOp: GroupOperation {
    
    init(context: TripContextProtocol) {
        let context = context as! UpdateTripContext
        
        var operations: [PSOperation] = []
        if context.trip.photo == nil && context.image != nil {
            // The trip did not originally have a photo, and now it has one. We need to upload the new one and update the trip/core data
            let uploadTripPhotoGroupOp = UploadTripPhotoGroupOp(trip: context.trip, context: context)
            let updateTripPhotoCDOp = UpdateTripPhotoCD(context: context)
            updateTripPhotoCDOp.addDependency(uploadTripPhotoGroupOp)
            operations = [uploadTripPhotoGroupOp, updateTripPhotoCDOp]
        } else if context.trip.photo != nil && context.image == nil {
            // Originally, the trip contained a photo, but the user deleted the trip
            // Delete the current photo on firebase, update the trip's properties, then update the trips photoUID, and then update core data
            let deleteCurrentTripPhotoOp = DeleteCurrentTripPhotoOp(context: context)
            let removePhotoUIDFromTripOp = RemoveTripUID(context: context)
            let updateTripPhotoCDOp = UpdateTripPhotoCD(context: context)
            removePhotoUIDFromTripOp.addDependency(deleteCurrentTripPhotoOp)
            updateTripPhotoCDOp.addDependency(deleteCurrentTripPhotoOp)
            operations = [deleteCurrentTripPhotoOp, removePhotoUIDFromTripOp, updateTripPhotoCDOp]
        }
        if let tripPhoto = context.trip.photo,
            let image = context.image {
            if tripPhoto.image != image {
                let deleteCurrentTripPhotoOp = DeleteCurrentTripPhotoOp(context: context)
                let uploadTripPhotoGroupOp = UploadTripPhotoGroupOp(trip: context.trip, context: context)
                let updateTripPhotoCDOp = UpdateTripPhotoCD(context: context)
                updateTripPhotoCDOp.addDependency(uploadTripPhotoGroupOp)
                operations = [deleteCurrentTripPhotoOp, uploadTripPhotoGroupOp, updateTripPhotoCDOp]
            }
        }
        super.init(operations: operations)
    }
}

class DeleteCurrentTripPhotoOp: PSOperation {
    
    var context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
        super.init()
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
    
    var context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
        super.init()
    }
    
    override func execute() {
        context.firestoreService.update(object: context.trip, fieldsAndCriteria: ["photoUID" : [""]], with: .update) { [weak self] (result) in
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

class UpdateTripPhotoCD: PSOperation {
    let context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
        super.init()
    }
    
    override func execute() {
        if let context = context as? UpdateTripContext {
            if context.trip.photo != nil && context.image == nil  {
                CoreDataManager.delete(object: context.trip.photo!)
                finish()
                return
            } else if context.image != context.trip.photo?.image {
                if let tripPhoto = context.trip.photo {
                    CoreDataManager.delete(object: tripPhoto)
                }
                guard let photoData = context.image?.pngData() else { finish() ; return }
                let _ = Photo(photo: photoData, place: nil, trip: context.trip)
                CoreDataManager.save()
            }
            finish()
        }
    }
}
