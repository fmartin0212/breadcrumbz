//
//  UploadPlacesOperation.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import PSOperations

class UploadPlacesOperation: GroupOperation {
    
    init(for trip: Trip, with context: SaveTripContext) {
        if let places = trip.places?.allObjects as? [Place],
            places.count > 0 {
            let operations = places.map { UploadPlaceOperation(place: $0, context: context) }
            super.init(operations: operations)
        } else {
            super.init(operations: [])
        }
    }
}

class UploadPlaceOperation: GroupOperation {
    
    init(place: Place, context: SaveTripContext) {
        let savePlace = SavePlaceOperation(place: place, context: context)
        
        if let photos = place.photos?.allObjects as? [Photo],
            photos.count > 0 {
            let savePhotos = photos.map { SavePhotoOperation(photo: $0, context: context) }
            savePhotos.forEach { $0.addDependency(savePlace) }
            super.init(operations: [savePlace] + savePhotos)
        } else {
            super.init(operations: [])
        }
    }
}
