//
//  Place+CoreDataProperties.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/12/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var address: String
    @NSManaged public var comments: String?
    @NSManaged public var name: String
    @NSManaged public var rating: Int16
    @NSManaged public var type: String
    @NSManaged public var photos: NSSet?
    @NSManaged public var trip: Trip

}

// MARK: Generated accessors for photos
extension Place {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
