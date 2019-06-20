//
//  DeleteTripPhotoFromCoreDataOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripPhotoFromCoreData: PSOperation {
    let context: DeleteTripContext
    
    init(context: DeleteTripContext) {
        self.context = context
    }
    
    override func execute() {
        guard let photo = context.trip.photo else { finish() ; return }
        CoreDataManager.delete(object: photo)
        finish()
    }
}
