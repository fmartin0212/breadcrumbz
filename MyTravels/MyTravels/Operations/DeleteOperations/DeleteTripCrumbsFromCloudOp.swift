//
//  DeleteTripCrumbsFromCloudOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripCrumbsFromCloudOp: PSOperation {
    let context: DeleteTripContext
    
    init(context: DeleteTripContext) {
        self.context = context
    }
    
    override func execute() {
        guard context.error != nil,
            let crumbs = context.trip.places?.allObjects as? [Place],
            crumbs.count > 0,
            crumbs.first?.uid != nil
            else { finish() ; return }
        
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
