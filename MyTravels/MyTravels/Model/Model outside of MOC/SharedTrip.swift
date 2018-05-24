//
//  LocalTrip.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class SharedTrip {
    
    let name: String
    let location: String
    let tripDescription: String?
    let startDate: Date
    let endDate: Date
    var photoData: Data?
    var places: [SharedPlace] = []
    var reference: CKReference {
        if let recordID = cloudKitRecordID {
            let reference = CKReference(recordID: recordID, action: .none)
            return reference
        }
        let failedRecordID = CKRecordID(recordName: "FAIL")
        return CKReference(recordID: failedRecordID, action: .none)
    }
    let cloudKitRecordID: CKRecordID?
    let creatorRef: CKReference
    var isAcceptedTrip: Bool = true
    
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        guard let photoData = photoData else { return fileURL }
        
        try? photoData.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    // CloudKit - Turn a record into a Trip
    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
            let location = record["location"] as? String,
            let tripDescription = record["tripDescription"] as? String,
            let startDate = record["startDate"] as? Date,
            let endDate = record["endDate"] as? Date,
            let photoData = record["photo"] as? CKAsset,
            let ckRecordID = record["recordID"] as? CKRecordID,
            let creatorRef = record["creatorReference"] as? CKReference
            else { return nil }
        
        let photoAssetAsData = try? Data(contentsOf: photoData.fileURL)
        
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = startDate
        self.endDate = endDate
        self.photoData = photoAssetAsData
        self.cloudKitRecordID = ckRecordID
        self.creatorRef = creatorRef
    }
}

extension SharedTrip: Equatable {
    static func == (lhs: SharedTrip, rhs: SharedTrip) -> Bool {
        return lhs.cloudKitRecordID == rhs.cloudKitRecordID
    }
}
