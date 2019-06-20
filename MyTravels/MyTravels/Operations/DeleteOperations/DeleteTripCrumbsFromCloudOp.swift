//
//  DeleteTripCrumbsFromCloudOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteCrumbParentGroupOp: GroupOperation {
    init(crumb: Place, context: TripContextProtocol) {
        let deleteCrumbPhotosGroupOp = DeleteCrumbPhotosGroupOp(crumb: crumb, context: context)
        let deleteCrumbGroupOp = DeleteCrumbGroupOp(crumb: crumb, context: context)
        deleteCrumbGroupOp.addDependency(deleteCrumbPhotosGroupOp)
        super.init(operations: [deleteCrumbPhotosGroupOp, deleteCrumbGroupOp])
    }
}

class DeleteCrumbGroupOp: GroupOperation {
    
    init(crumb: Place, context: TripContextProtocol) {
        let deleteCrumbFromCloudOp = DeleteCrumbFromCloudOp(crumb: crumb, context: context)
        let deleteCrumbFromCoreDataOp = DeleteObjectFromCoreData(object: crumb)
        deleteCrumbFromCoreDataOp.addDependency(deleteCrumbFromCloudOp)
        super.init(operations: [deleteCrumbFromCloudOp, deleteCrumbFromCoreDataOp])
    }
}

class DeleteCrumbPhotosGroupOp: GroupOperation {
    init(crumb: Place, context: TripContextProtocol) {
        let deleteCrumbPhotosFromCloudGroupOp = DeleteCrumbPhotosFromCloudOp(crumb: crumb, context: context)
        let deleteCrumbPhotosFromCoreDataOp = DeleteCrumbPhotosFromCoreDataOp(crumb: crumb)
        deleteCrumbPhotosFromCoreDataOp.addDependency(deleteCrumbPhotosFromCloudGroupOp)
        super.init(operations: [deleteCrumbPhotosFromCloudGroupOp, deleteCrumbPhotosFromCoreDataOp])
    }
}

class DeleteCrumbPhotosFromCoreDataOp: GroupOperation {
    init(crumb: Place) {
        if let allCrumbPhotos = crumb.photos?.allObjects.compactMap({ ($0 as? Photo) }),
            allCrumbPhotos.count > 0 {
            let deleteObjectOps = allCrumbPhotos.map { DeleteObjectFromCoreData(object: $0) }
            super.init(operations: deleteObjectOps)
        } else { super.init(operations: []) }
    }
}

class DeleteCrumbPhotosFromCloudOp: GroupOperation {
    init(crumb: Place, context: TripContextProtocol) {
        if let allCrumbPhotos = crumb.photos?.allObjects.compactMap({ ($0 as? Photo) }),
            allCrumbPhotos.count > 0 {
            let deleteObjectOps = allCrumbPhotos.map { DeleteObjectFromStorageOp(object: $0, context: context) }
            super.init(operations: deleteObjectOps)
        } else { super.init(operations: []) }
    }
}

/*
 Deletes all of the crumbs from both the cloud and local persistence for a trip.
*/
class DeleteTripCrumbsGroupOp: GroupOperation {
    init(context: DeleteTripContext) {
        if let crumbs = context.trip.places?.allObjects as? [Place],
            crumbs.count > 0,
            crumbs.first?.uid != nil {
            let deleteTripCrumbsFromCloudOp = DeleteTripCrumbsFromCloudOp(context: context)
            let deleteTripCrumbsFromCoreDataOp = DeleteTripCrumbsFromCoreDataOp(context: context)
            deleteTripCrumbsFromCoreDataOp.addDependency(deleteTripCrumbsFromCloudOp)
            super.init(operations: [deleteTripCrumbsFromCloudOp, deleteTripCrumbsFromCoreDataOp])
        } else { super.init(operations: []) }
    }
}

class DeleteTripCrumbsFromCoreDataOp: PSOperation {
    let context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
    }
    
    override func execute() {
        let crumbs = context.trip.places?.allObjects as! [Place]
        crumbs.forEach { CoreDataManager.delete(object: $0) }
        finish()
    }
}

class DeleteTripCrumbsFromCloudOp: PSOperation {
    let context: DeleteTripContext
    
    init(context: DeleteTripContext) {
        self.context = context
    }
    
    override func execute() {
        let crumbs = context.trip.places?.allObjects as! [Place]
        let crumbUIDs = crumbs.map { $0.uid ?? "" }
        context.firestoreService.batchDelete(collection: Place.collectionName, firestoreUIDs: crumbUIDs) { [weak self] (result) in
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
