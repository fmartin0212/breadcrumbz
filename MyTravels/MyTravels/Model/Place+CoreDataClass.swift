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
public class Place: NSManagedObject, FirebaseSavable {

    // FirebaseSavable
    var uuid: String?
    static var referenceName: String = Constants.place
    var dictionary: [String : Any] {
        return [
            "name" : self.name,
            "type" : self.type,
            "address" : self.address,
            "rating" : self.rating,
            "comments" : (self.comments ?? "")
        ]
    }
    
    convenience init(name: String, type: String, address: String, comments: String, rating: Int16, trip: Trip, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.name = name
        self.type = type
        self.address = address
        self.comments = comments
        self.rating = rating
        self.trip = trip
    }
}


