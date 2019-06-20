//
//  DeleteObjectFromCoreData.swift
//  MyTravels
//
//  Created by Frank Martin on 6/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations
import CoreData

class DeleteObjectFromCoreData: PSOperation {
    let object: NSManagedObject
    
    init(object: NSManagedObject) {
        self.object = object
    }
    
    override func execute() {
        CoreDataManager.delete(object: object)
    }
}
