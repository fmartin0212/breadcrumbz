//
//  DeleteTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripContext: TripContextProtocol {
    let trip: Trip
    var error: FireError?
    let firestoreService: FirestoreServiceProtocol
    var firebaseStorageService: FirebaseStorageServiceProtocol
    
    init(trip: Trip,
         firestoreService: FirestoreServiceProtocol = FirestoreService(),
         firebaseStorageService: FirebaseStorageService = FirebaseStorageService()) {
        self.trip = trip
        self.firestoreService = firestoreService
        self.firebaseStorageService = firebaseStorageService
    }
}

class DeleteTripGroupOp: GroupOperation {
    init(trip: Trip, completion: @escaping (Result<Bool, FireError>) -> Void) {
        let context = DeleteTripContext(trip: trip)
        let deleteTripPhotoFromCloudOp = DeleteTripPhotoFromCloudOp(context: context)
        let deleteTripPhotoFromCoreDataOp = DeleteTripPhotoFromCloudOp(context: context)
        let deleteAllCrumbsGroupOp = DeleteTripCrumbsGroupOp(context: context)
        let deleteTripFromCloudOp = DeleteTripFromCloudOp(context: context)
        let deleteTripFromCoreDataOp = DeleteObjectFromCoreData(object: context.trip)
        deleteTripPhotoFromCoreDataOp.addDependency(deleteTripPhotoFromCloudOp)
        deleteTripFromCloudOp.addDependency(deleteAllCrumbsGroupOp)
        deleteTripFromCoreDataOp.addDependency(deleteTripFromCloudOp)
        super.init(operations: [deleteTripPhotoFromCloudOp, deleteTripPhotoFromCoreDataOp, deleteAllCrumbsGroupOp, deleteTripFromCoreDataOp, deleteTripFromCloudOp])
    }
}


