//
//  Trip + Convenience.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

extension Trip {
    
    convenience init(location: String, startDate: Date, endDate: Date, photo: Data, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.photo = photo
    }
    
}

// FIXME: - CloudKit convenience initializer
