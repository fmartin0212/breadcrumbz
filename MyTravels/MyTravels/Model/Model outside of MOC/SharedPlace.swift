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
    init?(dictionary: [String : Any]) {
        
        guard let name = dictionary["name"] as? String,
            let address = dictionary["address"] as? String,
            let rating = dictionary["rating"] as? Int16,
            let type = dictionary["type"] as? String,
            let comments = dictionary["comments"] as? String
            else { return nil }
    
        self.name = name
        self.address = address
        self.rating = rating
        self.type = type
        self.comments = comments
    }
}
