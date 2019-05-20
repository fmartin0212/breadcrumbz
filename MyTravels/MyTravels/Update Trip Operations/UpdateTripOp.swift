//
//  UpdateTripOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateTripOp: PSOperation {
    let context: UpdateTripContext
    
    init(context: UpdateTripContext) {
        self.context = context
    }
    
    override func execute() {
        context.firestoreService.save(object: context.trip) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.finish()
            case .failure(let error):
                self?.context.error = error
            }
        }
    }
}

class SaveToLocalPersistence: PSOperation {
    let context: UpdateTripContext
    
    init(context: UpdateTripContext) {
        self.context = context
    }
    
    override func execute() {
        
    }
}
