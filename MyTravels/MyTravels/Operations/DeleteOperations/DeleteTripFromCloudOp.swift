//
//  DeleteTripFromCloudOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripFromCloudOp: PSOperation {
    let context: DeleteTripContext
    
    init(context: DeleteTripContext) {
        self.context = context
    }
    
    override func execute() {
        guard let _ = context.trip.uid else { finish() ; return }
        context.firestoreService.delete(object: context.trip) { [weak self] (result) in 
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
