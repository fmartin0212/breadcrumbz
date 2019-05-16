//
//  Place+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Place)
public class Place: NSManagedObject, FirestoreSavable, FirebaseDBSavable, CrumbObject {
    internal static var collectionName: String = "Crumb"

    // FirebaseSavable
    var uuid: String?
    static var referenceName: String = Constants.crumb
    var dictionary: [String : Any] {
        return [
            "name" : self.name,
            "type" : self.type!.rawValue,
            "address" : self.address,
            "rating" : self.rating,
            "comments" : (self.comments ?? ""),
            "tripUID" : (self.trip.uid ?? "")
        ]
    }
    
    enum types: String {
        case restaurant
        case lodging
        case activity
    }
    
    var type: types? {
        guard let placeType = placeType else { return nil }
        return Place.types(rawValue: placeType.type)!
    }
    
    convenience init(name: String, address: String, comments: String, rating: Int16, trip: Trip, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        self.address = address
        self.comments = comments
        self.rating = rating
        self.trip = trip
    }
}

