//
//  Trip+CoreDataProperties.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 10/15/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var endDate: NSDate
    @NSManaged public var location: String
    @NSManaged public var name: String
    @NSManaged public var startDate: NSDate
    @NSManaged public var tripDescription: String?
    @NSManaged public var uid: String?
    @NSManaged public var photo: Photo?
    @NSManaged public var places: NSSet?

}

// MARK: Generated accessors for places
extension Trip {

    @objc(addPlacesObject:)
    @NSManaged public func addToPlaces(_ value: Place)

    @objc(removePlacesObject:)
    @NSManaged public func removeFromPlaces(_ value: Place)

    @objc(addPlaces:)
    @NSManaged public func addToPlaces(_ values: NSSet)

    @objc(removePlaces:)
    @NSManaged public func removeFromPlaces(_ values: NSSet)

}
