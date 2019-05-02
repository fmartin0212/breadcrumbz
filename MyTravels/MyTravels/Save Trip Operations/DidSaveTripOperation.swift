//
//  DidSaveTripOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class DidSaveTripOperation: PSOperation {
    
    let context: SaveTripContext
    let completion: (Result<Bool, FireError>) -> Void
    
    init(context: SaveTripContext, completion: @escaping (Result<Bool, FireError>) -> Void) {
        self.context = context
        self.completion = completion
        super.init()
    }
    
    override func execute() {
        if let e = context.error {
            completion(.failure(e))
        } else {
            completion(.success(true))
        }
    }
    
}
