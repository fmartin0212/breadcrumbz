//
//  UsersSharedWithRecordIDs+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/15/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UsersSharedWithRecordIDs)
public class UsersSharedWithRecordIDs: NSManagedObject {

    convenience init(recordID: String, trip: Trip, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.recordID = recordID
        self.trip = trip
    }
    
}
