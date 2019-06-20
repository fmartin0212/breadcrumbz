//
//  DeleteTripCrumbsFromCoreDataOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripCrumbsFromCoreDataOp: PSOperation {
    let context: DeleteTripContext
    
    init(context: DeleteTripContext) {
        self.context = context
    }
    
    override func execute() {
        guard let crumbs = context.trip.places?.allObjects as? [Place],
            crumbs.count > 0
            else { finish() ; return }
        crumbs.forEach { CoreDataManager.delete(object: $0) }
        finish()
    }
}

