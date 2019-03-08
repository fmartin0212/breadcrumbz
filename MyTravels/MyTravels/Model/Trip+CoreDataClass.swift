//
//  Trip+CoreDataClass.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Trip)
public class Trip: NSManagedObject, FirebaseDBSavable {
    // Firebase Savable
    var uuid: String?
    static var referenceName: String = Constants.trip
    var dictionary: [String : Any] {
        return [
            "name" : self.name,
            "location" : self.location,
            "description" : self.tripDescription as Any,
            "startDate" : self.startDate.timeIntervalSince1970,
            "endDate" : self.endDate.timeIntervalSince1970,
            "creatorName" : InternalUserController.shared.loggedInUser!.firstName,
            "creatorUsername" : InternalUserController.shared.loggedInUser!.username,
            "creatorID" : InternalUserController.shared.loggedInUser!.uuid ?? ""
//            "places" : self.placesDictionary
        ]
    }
    
//    var placesDictionary: [String : [String : Any]] {
//        var dictionary = [String : [String : Any]]()
//        guard let places = self.places?.allObjects as? [Place] else { return dictionary }
//        places.forEach {
//            dictionary[$0.name] = $0.dictionary
//        }
//        return dictionary
//    }
    
    convenience init(name: String, location: String, tripDescription: String?, startDate: Date, endDate: Date, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        self.name = name
        self.location = location
        self.tripDescription = tripDescription
        self.startDate = startDate as NSDate
        self.endDate = endDate as NSDate
    }
}



