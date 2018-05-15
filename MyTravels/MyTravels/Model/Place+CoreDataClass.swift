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
    
    var recordType: String {
        return "Place"
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDString = cloudKitRecordIDString else { return nil}
        return CKRecordID(recordName: recordIDString)
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

// CloudKit - Turn a Place into a record
extension CKRecord {
    convenience init(place: Place, trip: Trip) {
        
        let ckRecordID = place.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)

        let photoAssets = place.temporaryPhotoURLs.map { CKAsset(fileURL: $0) }
        let ratingAsInt64 = Int(place.rating)
        let tripReference = trip.cloudKitReference
        
        self.init(recordType: "Place", recordID: ckRecordID)
        self.setValue(place.name, forKey: "name")
        self.setValue(place.address, forKey: "address")
        self.setValue(place.type, forKey: "type")
        self.setValue(place.comments, forKey: "comments")
        self.setValue(ratingAsInt64, forKey: "rating")
        self.setValue(photoAssets, forKey: "photos")
        self.setValue(tripReference, forKey: "tripReference")
        place.cloudKitRecordIDString = recordID.recordName
    }
}
