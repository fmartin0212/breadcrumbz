//
//  DeleteTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripContext {
    let trip: Trip
    let firestoreService: FirestoreServiceProtocol
    var error: FireError?
    
    init(trip: Trip, firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.trip = trip
        self.firestoreService = firestoreService
    }
}

class DeleteTripGroupOp: GroupOperation {
    
    init(trip: Trip, completion: @escaping (Result<Bool, FireError>) -> Void) {
        let context = DeleteTripContext(trip: trip)
        let deleteTripFromCloudOp = DeleteTripFromCloudOp(context: context)
        
        
        
        let deleteTripCrumbsFromCoreDataOp = DeleteTripCrumbsFromCoreDataOp(context: context)
        let deleteTripFromCoreDataOp = DeleteTripFromCoreDataOp(context: context)
        
        super.init(operations: [deleteTripFromCoreDataOp, deleteTripFromCloudOp])
    }
}


