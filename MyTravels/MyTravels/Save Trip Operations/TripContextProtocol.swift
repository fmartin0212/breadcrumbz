//
//  OperationProtocol.swift
//  MyTravels
//
//  Created by Frank Martin on 5/20/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation

protocol TripContextProtocol {
    var trip: Trip { get }
    var firestoreService: FirestoreServiceProtocol { get }
    var firebaseStorageService: FirebaseStorageServiceProtocol { get }
    var error: FireError? { get set }
}
