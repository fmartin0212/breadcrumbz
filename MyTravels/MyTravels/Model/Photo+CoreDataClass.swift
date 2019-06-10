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
public class Photo: NSManagedObject, FirebaseStorageSavable, FirestoreSyncable {
    var uuid: String?
    
    internal static var collectionName: String = "Photo"
    
    static var referenceName: String {
        return "Photo"
    }
    
    var data: Data {
        guard let photo = self.photo else { return Data() }
        let data = Data(referencing: photo)
        guard let image = UIImage(data: data),
            let compressedJPEGData = image.jpegData(compressionQuality: 0.1)
            else { return Data() }
        
        return compressedJPEGData
    }
    
    var image: UIImage {
        guard let data = self.photo,
            let image = UIImage(data: data as Data)
            else { return UIImage() }
        return image
    }
    
    @discardableResult
    convenience init(photo: Data, place: Place?, trip: Trip?, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.photo = NSData(data: photo)
        self.uid = UUID().uuidString
        self.place = place
        self.trip = trip
    }
}
