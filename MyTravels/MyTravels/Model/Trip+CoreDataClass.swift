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
import MapKit

@objc(Trip)
public class Trip: NSManagedObject, CloudKitSyncable {
    
    var recordType: String {
        return "Trip"
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDString = cloudKitRecordIDString
            else { return nil }
        return CKRecordID(recordName: recordIDString)
    }
    
    var reference: CKReference? {
        guard let cloudKitRecordID = cloudKitRecordID else { return nil }
        return CKReference(recordID: cloudKitRecordID, action: .deleteSelf)
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        guard let photo = self.photo?.photo else { return fileURL }
        
        try? photo.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    
    convenience init(name: String, location: String, tripDescription: String?, startDate: Date?, endDate: Date?, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // CloudKit - Turn a record into a Trip
    convenience public required init?(record: CKRecord, context: NSManagedObjectContext) {
        guard let location = record["location"] as? String,
            let startDate = record["startDate"] as? Date,
            let endDate = record["endDate"] as? Date
            else { return nil }
        
        self.init(context: context)
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.cloudKitRecordIDString = record.recordID.recordName
    }
}

// CloudKit - Turn a Trip into a record
extension CKRecord {
    
    convenience init?(trip: Trip) {
        
        let recordID = trip.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        let photoAsset = CKAsset(fileURL: trip.temporaryPhotoURL)
        
        self.init(recordType: "Trip", recordID: recordID)
        guard let loggedInUser = UserController.shared.loggedInUser, let loggedInUserCKRecordID = loggedInUser.ckRecordID else { return nil }
        let creatorReference = CKReference(recordID: loggedInUserCKRecordID, action: .none)
        
        var sharedIDsArray = [String]()
        if let sharedIDObjects = trip.usersSharedWithRecordIDs?.allObjects as? [UsersSharedWithRecordIDs] {
            for sharedIDObject in sharedIDObjects {
                if sharedIDObject.isSynced == false {
                    guard let sharedID = sharedIDObject.recordID else { return nil }
                    sharedIDsArray.append(sharedID)
                    sharedIDObject.isSynced = true
                }
            }
            CoreDataManager.save()
            self.setValue(sharedIDsArray, forKey: "userIDsTripSharedWith")
        }
        self.setValue(trip.name, forKey: "name")
        self.setValue(trip.location, forKey: "location")
        self.setValue(trip.tripDescription, forKey: "tripDescription")
        self.setValue(trip.startDate, forKey: "startDate")
        self.setValue(trip.endDate, forKey: "endDate")
        self.setValue(creatorReference, forKey: "creatorReference")
        self.setValue(photoAsset, forKey: "photo")
        trip.cloudKitRecordIDString = recordID.recordName
    }
}
