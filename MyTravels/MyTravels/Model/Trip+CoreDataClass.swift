//
//  Trip+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Trip)
public class Trip: NSManagedObject {
    
    convenience init(name: String, location: String, tripDescription: String?, startDate: Date, endDate: Date, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = startDate as NSDate
        self.endDate = endDate as NSDate
    }
}

