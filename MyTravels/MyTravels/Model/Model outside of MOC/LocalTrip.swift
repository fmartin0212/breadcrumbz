//
//  LocalTrip.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class LocalTrip {
    var location: String
    var startDate: Date
    var endDate: Date
    var photoData: Data?
    var places: [LocalPlace] = []
    var reference: CKReference {
        if let recordID = cloudKitRecordID {
            let reference = CKReference(recordID: recordID, action: .none)
            return reference
        }
        let failedRecordID = CKRecordID(recordName: "FAIL")
        return CKReference(recordID: failedRecordID, action: .none)
    }
    
    var cloudKitRecordID: CKRecordID?
    
        fileprivate var temporaryPhotoURL: URL {
    
            // Must write to temporary directory to be able to pass image file path url to CKAsset
    
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
    
            guard let photoData = photoData else { return fileURL }
    
            try? photoData.write(to: fileURL, options: [.atomic])
    
            return fileURL
        }
    
//    init(location: String, startDate: Date, endDate: Date, photoData: Data?) {
//        self.location = location
//        self.startDate = startDate
//        self.endDate = endDate
//        self.photoData = photoData
//    }
    
    // CloudKit - Turn a record into a Trip
    init?(record: CKRecord) {
        guard let location = record["location"] as? String,
            let startDate = record["startDate"] as? Date,
            let endDate = record["endDate"] as? Date,
            let photoData = record["photo"] as? CKAsset,
            let ckRecordID = record["recordID"] as? CKRecordID
            else { return nil }
        
        let photoAssetAsData = try? Data(contentsOf: photoData.fileURL)
        
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.photoData = photoAssetAsData
        self.cloudKitRecordID = ckRecordID
    }
}

//// Trip into a record
//extension CKRecord {
//
//    convenience init?(trip: LocalTrip) {
//
//        let recordID = trip.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
//        let photoAsset = CKAsset(fileURL: trip.temporaryPhotoURL)
//
//        self.init(recordType: "Trip", recordID: recordID)
//        guard let loggedInUser = UserController.shared.loggedInUser else { return nil }
//        let creatorReference = CKReference(recordID: loggedInUser.appleUserRef.recordID, action: .none)
//
//        self.setValue(trip.location, forKey: "location")
//        self.setValue(trip.startDate, forKey: "startDate")
//        self.setValue(trip.endDate, forKey: "endDate")
//        self.setValue(photoAsset, forKey: "photo")
//        self.setValue(creatorReference, forKey: "creatorReference")
//    }
//}

