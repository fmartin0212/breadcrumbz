//
//  UpdateTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateTripGroupOp: GroupOperation {
    
    init(trip: Trip, image: UIImage?, name: String, location: String, startDate: Date, endDate: Date, tripDescription: String?, completion: @escaping (Result<Bool, FireError>) -> Void) {
        let context = UpdateTripContext(trip: trip, image: image)
        let updateTripOp = UpdateTripOp(trip: trip, context: context, image: image, name: name, location: location, startDate: startDate, endDate: endDate, tripDescription: tripDescription)
        let updateCompleteOp = UpdateCompleteOp(context: context, completion: completion)
        updateCompleteOp.addDependency(updateTripOp)
        super.init(operations: [updateTripOp, updateCompleteOp])
    }
}

class UpdateCompleteOp: PSOperation {
    
    let context: TripContextProtocol
    let completion: (Result<Bool, FireError>) -> Void
   
    init(context: TripContextProtocol, completion: @escaping (Result<Bool, FireError>) -> Void) {
        self.context = context
        self.completion = completion
    }
    
    override func execute() {
        guard context.error == nil else { completion(.failure(context.error!)) ; finish() ; return }
        completion(.success(true))
        finish()
    }
}

class UpdateTripOp: GroupOperation {
   
    init(trip: Trip, context: TripContextProtocol, image: UIImage?, name: String, location: String, startDate: Date, endDate: Date, tripDescription: String?) {
        if trip.name == name &&
            trip.location == location &&
            trip.startDate == startDate as NSDate &&
            trip.endDate == endDate as NSDate &&
            trip.tripDescription == tripDescription &&
            trip.photo?.image == image {
            super.init(operations: [])
        } else {
            if trip.uid == nil {
                let updateTripOnLocalPersistence = UpdateTripOnLocalPersistence(context: context, name: name, location: location, startDate: startDate, endDate: endDate, tripDescription: tripDescription)
                let updateTripPhotoCD = UpdateTripPhotoCD(context: context)
                super.init(operations: [updateTripOnLocalPersistence, updateTripPhotoCD])
            } else {
                let updateTripOnLocalPersistence = UpdateTripOnLocalPersistence(context: context, name: name, location: location, startDate: startDate, endDate: endDate, tripDescription: tripDescription)
                let updateTripOnCloudPersistenceOp = UpdateTripOnCloudPersistenceOp(context: context)
                let updateTripPhotoGroupOp = UpdateTripPhotoGroupOp(context: context)
                updateTripOnCloudPersistenceOp.addDependency(updateTripOnLocalPersistence)
                updateTripPhotoGroupOp.addDependency(updateTripOnCloudPersistenceOp)
                super.init(operations: [updateTripOnLocalPersistence, updateTripOnCloudPersistenceOp, updateTripPhotoGroupOp])
            }
        }
    }
}

class UpdateTripOnLocalPersistence: PSOperation {
    let context: TripContextProtocol
    let tripName: String
    let location: String
    let startDate: Date
    let endDate: Date
    var tripDescription: String?
    
    init(context: TripContextProtocol, name: String, location: String, startDate: Date, endDate: Date, tripDescription: String?) {
        self.context = context
        self.tripName = name
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.tripDescription = tripDescription
    }
    
    override func execute() {
        let trip = context.trip
        trip.name = tripName
        trip.location = location
        trip.startDate = startDate as NSDate
        trip.endDate = endDate as NSDate
        trip.tripDescription = tripDescription
        CoreDataManager.save()
        finish()
    }
}
