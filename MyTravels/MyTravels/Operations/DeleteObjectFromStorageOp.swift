//
//  DeleteObjectFromStorageOp.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DeleteObjectFromStorageOp: PSOperation {
    let object: FirebaseStorageSavable
    let context: OperationContextProtocol
    
    init(object: FirebaseStorageSavable, context: OperationContextProtocol) {
        self.object = object
        self.context = context
    }
    
    override func execute() {
        context.firebaseStorageService.delete(object: object) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.finish()
            case .failure(_):
                self?.finish()
            }
        }
    }
}
