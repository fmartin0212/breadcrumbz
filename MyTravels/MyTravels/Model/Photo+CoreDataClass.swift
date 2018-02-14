//
//  Photo+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData
import CloudKit

@objc(Photo)
public class Photo: NSManagedObject, CloudKitSyncable {

    var recordType: String {
        return "Photo"
    }
    
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDString = cloudKitRecordIDString else { return nil}
        return CKRecordID(recordName: recordIDString)
    }
    
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        guard let photo = self.photo else { return fileURL }
        
        try? photo.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    convenience init(photo: Data, place: Place?, trip: Trip?, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.photo = photo as NSData?
        self.place = place
        self.trip = trip
    }
    
    // CloudKit - Turn a record into a Photo
    required convenience public init?(record: CKRecord, context: NSManagedObjectContext) {
        self.init(context: context)
        guard let photo = record["photo"] as? NSData
            else { return }
        
        self.photo = photo
    }
    
}

extension CKRecord {
    
    convenience init(photo: Photo, trip: Trip) {
        let recordID = photo.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: "Photo", recordID: recordID)
        
        let photoAsset = CKAsset(fileURL: photo.temporaryPhotoURL)
//        guard let tripRecordID = trip.cloudKitRecordID else { return }
        let tripReference = trip.cloudKitReference
        
        self.setValue(photoAsset, forKey: "photo")
        self.setValue(tripReference, forKey: "tripReference")
        
    }
    
    convenience init(photo: Photo, place: Place) {
        
        let recordID = photo.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: "Photo", recordID: recordID)
        
        let photoAsset = CKAsset(fileURL: photo.temporaryPhotoURL)
//        guard let placeRecordID = place.cloudKitRecordID else { return }
        let placeReference = place.cloudKitReference
        
        self.setValue(photoAsset, forKey: "photo")
        self.setValue(placeReference, forKey: "placeReference")
        
    }
    
    
}
