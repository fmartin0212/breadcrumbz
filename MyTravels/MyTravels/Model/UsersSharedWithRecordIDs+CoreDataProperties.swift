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
