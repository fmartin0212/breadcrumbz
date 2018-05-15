//
//  LocalPlace.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class SharedPlace {
    
    var address: String?
    var comments: String?
    var name: String?
    var rating: Int16?
    var type: String?
    var photos: [Data]?
    var reference: CKReference?
    
    fileprivate var temporaryPhotoURLs: [URL] {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        var photoURLs: [URL] = []
        guard let photos = photos else { return [URL]() }
        for photo in photos {
            let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
            try? photo.write(to: fileURL, options: [.atomic])
            photoURLs.append(fileURL)
        }
        
        return photoURLs
    }
    
    // CloudKit - Turn a record into a Place
    init?(record: CKRecord) {
        
        guard let name = record["name"] as? String,
            let address = record["address"] as? String,
            let rating = record["rating"] as? Int16,
            let type = record["type"] as? String,
            let comments = record["comments"] as? String,
            let photos = record["photos"] as? [CKAsset],
            let reference = record["tripReference"] as? CKReference
            else { return nil }
        
        var photosAsData = [Data]()
        if photos.count > 0 {
            for photo in photos {
                guard let photoAssetAsData = try? Data(contentsOf: photo.fileURL) else { return }
                photosAsData.append(photoAssetAsData)
            }
        }
        self.name = name
        self.address = address
        self.rating = rating
        self.type = type
        self.comments = comments
        self.photos = photosAsData
        self.reference = reference
        
    }
    
}
