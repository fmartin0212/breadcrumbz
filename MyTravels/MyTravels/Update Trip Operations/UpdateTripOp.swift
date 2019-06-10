//
//  UpdateTripOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateTripOnCloudPersistenceOp: PSOperation {
    var context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
        super.init()
    }
    
    override func execute() {
        context.firestoreService.update(object: context.trip, fieldsAndCriteria: context.trip.dictionary, with: .update) { [weak self] (result) in
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

