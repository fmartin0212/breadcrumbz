//
//  PlaceType+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/6/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PlaceType)
public class PlaceType: NSManagedObject {

}

extension PlaceType {
    
    convenience init(type: Place.types, place: Place, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.type = type.rawValue
        self.place = place
    }
}
