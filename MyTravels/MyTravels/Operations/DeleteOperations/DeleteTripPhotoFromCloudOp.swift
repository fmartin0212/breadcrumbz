//
//  DeleteTripPhotoFromCloudOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/20/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteTripPhotoFromCloudOp: PSOperation {
    var context: TripContextProtocol
    
    init(context: TripContextProtocol) {
        self.context = context
    }
    
    override func execute() {
        guard let photo = context.trip.photo else { finish() ; return }
        context.firebaseStorageService.delete(object: photo) { [weak self] (result) in
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
