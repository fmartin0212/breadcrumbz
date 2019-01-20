//
//  Photo+CoreDataProperties.swift
//  
//
//  Created by Frank Martin Jr on 1/19/19.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var firebaseURL: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var uid: String?
    @NSManaged public var place: Place?
    @NSManaged public var trip: Trip?

}
