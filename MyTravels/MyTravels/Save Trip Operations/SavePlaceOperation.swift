//
//  SavePlaceOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class SavePlaceOperation: PSOperation {
    
    init(place: Place, context: SaveTripContext) {
        context.service.save(object: place) { (result) in
            switch result {
            case .failure(let error):
                context.error = error
            case .success(let placeUID):
                context.placeUIDs.append(placeUID)
            }
        }
        super.init()
    }
}
