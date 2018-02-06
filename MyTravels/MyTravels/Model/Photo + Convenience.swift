//
//  Photo + Convenience.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/5/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    convenience init(photo: Data, place: Place?, trip: Trip?, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.photo = photo
        self.place = place
        self.trip = trip
    }
    
}

// FIXME: - CloudKit convenience initializer
