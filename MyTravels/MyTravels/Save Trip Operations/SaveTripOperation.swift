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
    
    init(trip: Trip, service: FirestoreServiceProtocol, completion: @escaping (Result<Bool, SaveTripError>) -> Void) {
        
        let context = SaveTripContext(trip: trip, service: service)
        let uploadTrip = UploadTripOperation(context: context)
        let saveTripToCD = SaveCoreDataOperation()
        
        let savePhotos = SavePhotoOperation()
        let done = DidSaveTripOperation(context: context, completion: completion)
        
        saveTripToCD.addDependency(uploadTrip)
        done.addDependency(savePhotos)
        
        super.init(operations: [save, saveCD, savePhotos, done])
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
                    self.context.error = .uploadTripFailed(error)
            }
            
            self.finish()
        }
    }
}
