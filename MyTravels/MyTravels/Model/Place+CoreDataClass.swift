//
//  Place+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Place)
public class Place: NSManagedObject, CloudKitSyncable {

    var uid: String?
    
    var recordType: String {
        return "Place"
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDString = cloudKitRecordIDString else { return nil}
        return CKRecordID(recordName: recordIDString)
    }
    
    var reference: CKReference? {
        guard let cloudKitRecordID = cloudKitRecordID else { return nil }
        return CKReference(recordID: cloudKitRecordID, action: .deleteSelf)
    }
    
    fileprivate var temporaryPhotoURLs: [URL] {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        var photoURLs: [URL] = []
        guard let photos = self.photos?.allObjects as? [Photo] else { return [URL]() }
        for photo in photos {
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
            try? photo.photo?.write(to: fileURL, options: [.atomic])
            photoURLs.append(fileURL)
        }
        return photoURLs
    }

    convenience init(name: String, type: String, address: String, comments: String, rating: Int16, trip: Trip, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.name = name
        self.type = type
        self.address = address
        self.comments = comments
        self.rating = rating
        self.trip = trip
    }
    
    // CloudKit - Turn a record into a Place
    required convenience public init?(record: CKRecord, context: NSManagedObjectContext) {
        self.init(context: context)
        guard let name = record["name"] as? String,
            let address = record["address"] as? String,
            let type = record["type"] as? String,
            let comments = record["comments"] as? String
//            let photos = record["photos"] as? NSSet
            else { return }
        
        self.name = name
        self.address = address
        self.type = type
        self.comments = comments
//        self.photos = photos
    }
}


