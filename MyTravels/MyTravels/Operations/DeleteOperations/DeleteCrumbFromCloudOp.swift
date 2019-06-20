//
//  DeleteCrumbOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteCrumbFromCloudOp: PSOperation {
    let crumb: Place
    let context: TripContextProtocol
    
    init(crumb: Place, context: TripContextProtocol) {
        self.crumb = crumb
        self.context = context
    }
    
    override func execute() {
        context.firestoreService.delete(object: crumb) { [weak self] (_) in
            self?.finish()
        }
    }
}
