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
    var context: TripContextProtocol
    let firebaseStorageService: FirebaseStorageServiceProtocol
    
    init(photo: Photo, context: TripContextProtocol) {
        self.photo = photo
        self.firebaseStorageService = FirebaseStorageService()
        self.context = context
        super.init()
    }
    
    override func execute() {
        firebaseStorageService.save(photo) { [weak self] (result) in
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
