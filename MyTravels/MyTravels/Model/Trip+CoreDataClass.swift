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

    var recordType: String {
        return "Trip"
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDString = cloudKitRecordIDString
            else { return nil}
        return CKRecordID(recordName: recordIDString)
    }
    
    convenience init(location: String, startDate: Date?, endDate: Date?, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
//        self.cloudKitRecordIDString = cloudKitRecordIDString
        
    }
    
    // CloudKit - Turn a record into a Trip
    required convenience public init?(record: CKRecord, context: NSManagedObjectContext) {
        self.init(context: context)
        self.location = record["location"] as? String
        self.startDate = record["startDate"] as? Date
        self.endDate = record["endDate"] as? Date
        self.cloudKitRecordIDString = record["recordName"] as? String
        
    }
}

    // CloudKit - Turn a Trip into a record
extension CKRecord {
    
    convenience init?(trip: Trip) {
        
        let recordID = trip.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
//        let photoAsset = CKAsset(fileURL: trip.temporaryPhotoURL)
        
        self.init(recordType: "Trip", recordID: recordID)
        guard let loggedInUser = UserController.shared.loggedInUser else { return nil }
        let creatorReference = CKReference(recordID: loggedInUser.appleUserRef.recordID, action: .none)
        
        var sharedIDsArray = [String]()
        if let sharedIDObjects = trip.usersSharedWithRecordIDs?.allObjects as? [UsersSharedWithRecordIDs] {
            for sharedIDObject in sharedIDObjects {
                guard let sharedID = sharedIDObject.recordID else { return nil }
                sharedIDsArray.append(sharedID)
            }
            self.setValue(sharedIDsArray, forKey: "userIDsTripSharedWith")
            self.setValue(trip.location, forKey: "location")
            self.setValue(trip.startDate, forKey: "startDate")
            self.setValue(trip.endDate, forKey: "endDate")
            self.setValue(creatorReference, forKey: "creatorReference")
        }
            
        else {
            self.setValue(trip.location, forKey: "location")
            self.setValue(trip.startDate, forKey: "startDate")
            self.setValue(trip.endDate, forKey: "endDate")
            self.setValue(creatorReference, forKey: "creatorReference")
            //        self.setValue(photoAsset, forKey: "photo")
        }
    }
}

//    fileprivate var temporaryPhotoURL: URL {
//
//        // Must write to temporary directory to be able to pass image file path url to CKAsset
//
//        let temporaryDirectory = NSTemporaryDirectory()
//        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
//        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
//
//        guard let photo = self.photo?.photo else { return fileURL }
//
//        try? photo.write(to: fileURL, options: [.atomic])
//
//        return fileURL
//    }



