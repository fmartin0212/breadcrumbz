//
//  UpdateTripContext.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class UpdateTripContext: TripContextProtocol {
    var trip: Trip
    var firestoreService: FirestoreServiceProtocol
    var firebaseStorageService: FirebaseStorageServiceProtocol
    var error: FireError?
    var image: UIImage?
    
    init(trip: Trip, image: UIImage?) {
        self.trip = trip
        self.image = image
        self.firestoreService = FirestoreService()
        self.firebaseStorageService = FirebaseStorageService()
    }
}
