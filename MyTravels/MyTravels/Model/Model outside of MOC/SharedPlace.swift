//
//  LocalPlace.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedPlace: FirebaseDBRetrievable {
    
    required init?(dictionary: [String : Any], uuid: String) {
        guard let name = dictionary["name"] as? String,
            let address = dictionary["address"] as? String,
            let rating = dictionary["rating"] as? Int16,
            let type = dictionary["type"] as? String,
            let comments = dictionary["comments"] as? String
            else { return nil }
        
        if let photoURLs = dictionary["photoURLs"] as? [String: [String : Any]] {
            self.photoURLs = photoURLs.compactMap({ (key, value) -> String? in
                let photoDict = value as! [String: String]
                for (_, value) in photoDict {
                    return value
                }
                return ""
            })
        }
        
        self.name = name
        self.address = address
        self.rating = rating
        self.type = type
        self.comments = comments
        self.uuid = uuid
    }
    
    var uuid: String?
    
    static var referenceName: String {
        return "Crumb"
    }
    
    
    var address: String
    var comments: String?
    var name: String
    var rating: Int16
    var type: String
    var photos: [UIImage] = []
    var photoURLs: [String]?

//    init?(dictionary: [String : Any]) {
//
//        guard let name = dictionary["name"] as? String,
//            let address = dictionary["address"] as? String,
//            let rating = dictionary["rating"] as? Int16,
//            let type = dictionary["type"] as? String,
//            let comments = dictionary["comments"] as? String
//            else { return nil }
//
//        if let photoURLs = dictionary["photoURLs"] as? [String: [String : Any]] {
//            self.photoURLs = photoURLs.compactMap({ (key, value) -> String? in
//                let photoDict = value as! [String: String]
//                for (_, value) in photoDict {
//                    return value
//                }
//                return ""
//            })
//        }
//
//        self.name = name
//        self.address = address
//        self.rating = rating
//        self.type = type
//        self.comments = comments
//    }
}
