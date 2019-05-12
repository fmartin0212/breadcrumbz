//
//  AddPhotoPathsToCrumbOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/9/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class AddPhotoPathToCrumbOp: PSOperation {
    
    let crumb: Place
    let photoPath: String
    let firestoreService: FirestoreServiceProtocol
    let context: SaveTripContext
    
    init(crumb: Place, photoPath: String, context: SaveTripContext) {
        self.crumb = crumb
        self.photoPath = photoPath
        self.firestoreService = context.service
        self.context = context
    }
    
    override func execute() {
        firestoreService.update(object: crumb, atField: "photoPaths", withCriteria: [photoPath], with: .arrayAddtion) { [weak self] (result) in
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
