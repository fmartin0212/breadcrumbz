//
//  SavePhotoOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class SavePhotoOperation: PSOperation {
    let photo: Photo
    let firebaseStorageService: FirebaseStorageServiceProtocol
    
    init(photo: Photo, context: SaveTripContext) {
        self.photo = photo
        self.firebaseStorageService = FirebaseStorageService()
    }
    
    override func execute() {
        firebaseStorageService.save(photo) { [weak self] (result) in
            self?.finish()
        }
    }
}
