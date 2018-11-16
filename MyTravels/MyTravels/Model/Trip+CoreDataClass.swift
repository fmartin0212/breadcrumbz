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
public class Trip: NSManagedObject {
    
    fileprivate var temporaryPhotoURL: URL {

        // Must write to temporary directory to be able to pass image file path url to CKAsset
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        guard let photo = self.photo?.photo else { return fileURL }
        
        try? photo.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    convenience init(name: String, location: String, tripDescription: String?, startDate: Date, endDate: Date, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = startDate as NSDate
        self.endDate = endDate as NSDate
    }
    
    // CloudKit - Turn a record into a Trip
    convenience public required init?(record: CKRecord, context: NSManagedObjectContext) {
        guard let location = record["location"] as? String,
            let startDate = record["startDate"] as? Date,
            let endDate = record["endDate"] as? Date
            else { return nil }
        
        self.init(context: context)
        self.location = location
        self.startDate = NSDate()
        self.endDate = NSDate()
        
    }
}

