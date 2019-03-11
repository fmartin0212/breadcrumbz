//
//  Trip+CrumbProtocols.swift
//  MyTravels
//
//  Created by Frank Martin on 3/9/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation

protocol TripObject {
    var name: String { get set }
    var startDate: NSDate { get set }
    var endDate: NSDate { get set }
    var location: String { get set }
    var tripDescription: String? { get set }
}

protocol CrumbObject {
    var address: String { get set }
    var comments: String? { get set }
    var name: String { get set }
    var type: Place.types? { get }
}
