//
//  Photo+CoreDataClass.swift
//  
//
//  Created by Frank Martin Jr on 1/19/19.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    convenience init(photo: Data, place: Place?, trip: Trip?, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.photo = NSData(data: photo)
        self.place = place
        self.trip = trip
        
    }
    
}
