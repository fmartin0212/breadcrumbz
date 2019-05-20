//
//  UpdateTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UpdateTripGroupOp: GroupOperation {
    init(trip: Trip, image: UIImage?) {
        let context = UpdateTripContext(trip: trip, image: image)
        let updateTripOp = UpdateTripOp(context: context)
        
        
        super.init(operations: [])
        
    }
    
}
