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
    let place: Place
    let context: SaveTripContext
    
    init(place: Place, context: SaveTripContext) {
        self.place = place
        self.context = context
        super.init()
    }
    
    override func execute() {
        guard context.error == nil else { finish() ; return }
        context.firestoreService.save(object: place) { [weak self] (result) in
            switch result {
            case .failure(let error):
                self?.context.error = error
                self?.finish()
            case .success(let placeUID):
                self?.context.placeUIDs.append(placeUID)
                self?.place.uuid = placeUID
                self?.place.uid = placeUID
                CoreDataManager.save()
                self?.finish()
            }
        }
    }
}
