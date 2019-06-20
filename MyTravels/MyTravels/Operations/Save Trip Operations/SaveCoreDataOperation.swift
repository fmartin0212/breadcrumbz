//
//  SaveCoreDataOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class SaveCoreDataOperation: PSOperation {
    
    override func execute() {
        CoreDataManager.save()
        finish()
    }
}
