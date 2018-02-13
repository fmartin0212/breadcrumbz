//
//  Photo+CoreDataProperties.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/12/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var cloudKitRecordIDString: String?
    @NSManaged public var place: Place?
    @NSManaged public var trip: Trip?

}
