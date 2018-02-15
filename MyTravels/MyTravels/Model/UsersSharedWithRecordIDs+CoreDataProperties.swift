//
//  UsersSharedWithRecordIDs+CoreDataProperties.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/15/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension UsersSharedWithRecordIDs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsersSharedWithRecordIDs> {
        return NSFetchRequest<UsersSharedWithRecordIDs>(entityName: "UsersSharedWithRecordIDs")
    }

    @NSManaged public var recordID: String?
    @NSManaged public var trip: Trip?

}

// MARK: Generated accessors for places
extension UsersSharedWithRecordIDs {
    
    @objc(addPlacesObject:)
    @NSManaged public func addToTrip(_ value: Trip)
    
    @objc(removePlacesObject:)
    @NSManaged public func removeFromTrips(_ value: Trip)
    
    @objc(addPlaces:)
    @NSManaged public func addToTrips(_ values: NSSet)
    
    @objc(removePlaces:)
    @NSManaged public func removeFromTrip(_ values: NSSet)
    
}
