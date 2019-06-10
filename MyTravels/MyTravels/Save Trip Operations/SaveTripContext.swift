//
//  SaveTripContext.swift
//  MyTravels
//
//  Created by Frank Martin on 4/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation

enum SaveTripError: Error {
    case uploadTripFailed(FireError)
    case savePhotoFailed(Photo)
    case updateUserFailed(FireError)    
}

class SaveTripContext: TripContextProtocol {
    
    var trip: Trip
    var firestoreService: FirestoreServiceProtocol
    var firebaseStorageService: FirebaseStorageServiceProtocol
    var error: FireError?
    var tripPhotoUID: String?
    var placeUIDs: [String] = []
    var photoPaths: [String] = []
    var receiver: InternalUser?
    var receiverIsBlocked: Bool = false
    
    init(trip: Trip, service: FirestoreServiceProtocol, storageService: FirebaseStorageServiceProtocol) {
        self.trip = trip
        self.firestoreService = service
        self.firebaseStorageService = storageService
    }
}
