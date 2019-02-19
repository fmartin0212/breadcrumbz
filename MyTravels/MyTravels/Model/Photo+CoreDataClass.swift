//
//  Photo+CoreDataClass.swift
//  
//
//  Created by Frank Martin Jr on 1/19/19.
//
//

import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject, FirebaseStorageSavable {
    
    static var referenceName: String {
        return "Photo"
    }
    
    var data: Data {
        guard let photo = self.photo else { return Data() }
        let data = Data(referencing: photo)
        guard let image = UIImage(data: data),
            let compressedJPEGData = UIImageJPEGRepresentation(image, 0.1)
            else { return Data() }
        
        return compressedJPEGData
    }
    
    convenience init(photo: Data, place: Place?, trip: Trip?, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.photo = NSData(data: photo)
        self.uid = UUID().uuidString
        self.place = place
        self.trip = trip
    }
}
