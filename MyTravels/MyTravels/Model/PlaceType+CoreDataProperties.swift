//
//  PlaceType+CoreDataProperties.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/6/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData

extension PlaceType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceType> {
        return NSFetchRequest<PlaceType>(entityName: "PlaceType")
    }

    @NSManaged public var type: String
    @NSManaged public var place: Place?

}
