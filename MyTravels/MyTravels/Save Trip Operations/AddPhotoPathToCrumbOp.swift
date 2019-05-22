//
//  AddPhotoPathsToCrumbOp.swift
//  MyTravels
//
//  Created by Frank Martin on 5/9/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class AddPhotoUIDsToCrumbOp: PSOperation {
    
    let crumb: Place
    let photoPath: String
    let firestoreService: FirestoreServiceProtocol
    let context: SaveTripContext
    
    init(crumb: Place, photoPath: String, context: SaveTripContext) {
        self.crumb = crumb
        self.photoPath = photoPath
        self.firestoreService = context.firestoreService
        self.context = context
        super.init()
    }
    
    override func execute() {
        firestoreService.update(object: crumb, fieldsAndCriteria: ["photoUIDs" : [photoPath]], with: .arrayAddition) { [weak self] (result) in
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
