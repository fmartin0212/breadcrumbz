//
//  OperationProtocol.swift
//  MyTravels
//
//  Created by Frank Martin on 5/20/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation

protocol TripContextProtocol: OperationContextProtocol {
    var trip: Trip { get set }
}

protocol CrumbContext: OperationContextProtocol {
    var crumb: Place { get set}
}

protocol OperationContextProtocol {
    var firestoreService: FirestoreServiceProtocol { get }
    var firebaseStorageService: FirebaseStorageServiceProtocol { get }
    var error: FireError? { get set }
}
