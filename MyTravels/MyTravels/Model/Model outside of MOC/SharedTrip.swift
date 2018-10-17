//
//  LocalTrip.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit
import FirebaseDatabase

class SharedTrip {
    
    let name: String
    let location: String
    let tripDescription: String?
    let startDate: Date
    let endDate: Date
    var photoData: Data?
    var places: [SharedPlace] = []
    var isAcceptedTrip: Bool = true
    
    var uid: String
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
        
        guard let photoData = photoData else { return fileURL }
        
        try? photoData.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    init?(snapshot: DataSnapshot) {
        self.uid = snapshot.key
        
        guard let tripDictionary = snapshot.value as? [String : Any],
            let name = tripDictionary["name"] as? String,
            let location = tripDictionary["location"] as? String,
            let tripDescription = tripDictionary["tripDescription"] as? String?,
            let startDate = tripDictionary["startDate"] as? TimeInterval,
            let endDate = tripDictionary["endDate"] as? TimeInterval
            else { return nil }
        
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = Date(timeIntervalSince1970: startDate)
        self.endDate = Date(timeIntervalSince1970: endDate)
        
        if let places = SharedPlaceController.parsePlacesFrom(tripDictionary: tripDictionary) {
            self.places = places
        }
    }
}

extension SharedTrip: Equatable {
    static func == (lhs: SharedTrip, rhs: SharedTrip) -> Bool {
        return lhs.uid == rhs.uid
    }
}
