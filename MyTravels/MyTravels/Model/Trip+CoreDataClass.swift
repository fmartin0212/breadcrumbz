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
import CloudKit

@objc(Trip)
public class Trip: NSManagedObject, CloudKitSyncable {
    
    // CloudKit - Turn a record into a trip
//    required init?(record: CKRecord, context: NSManagedObjectContext) {
//        self.init(context: context)
//        self.location = record["location"] as? String
//        self.startDate = record["startDate"] as? NSDate
//
//    }

    var recordType: String {
        return "Trip"
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDString = cloudKitRecordIDString else { return nil}
        return CKRecordID(recordName: recordIDString)
    }
    
    convenience init(location: String, startDate: Date?, endDate: Date?, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.location = location
        self.startDate = startDate as NSDate?
        self.endDate = endDate as NSDate?
        
    }
}
