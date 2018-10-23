//
//  SharedPlaceController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 10/16/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SharedPlaceController {
    
    static func parsePlacesFrom(tripDictionary: [String : Any], completion: @escaping ([SharedPlace]) -> Void) {
        guard let placesDictionary = tripDictionary["places"] as? [String : [String : Any]]
            else { completion([]) ; return }
        
        
        var sharedPlaces: [SharedPlace] = []
        
        for (_, value) in placesDictionary {
            guard let sharedPlace = SharedPlace(dictionary: value) else { completion([]) ; return }
            sharedPlaces.append(sharedPlace)
        }
        
        self.fetchSharedPlacesPhotos(sharedPlaces: sharedPlaces) { (success) in
            if success {
                completion(sharedPlaces)
            }
        }
    }
    
    static func fetchSharedPlacesPhotos(sharedPlaces: [SharedPlace], completion: @escaping (Bool) -> Void) {
        
        let dispatchGroup  = DispatchGroup()
        for sharedPlace in sharedPlaces {
            var placeImages: [UIImage] = []
            sharedPlace.photos = placeImages
           
            if let photoURLs = sharedPlace.photoURLs {
                for urlAsString in photoURLs {
                    guard let url = URL(string: urlAsString) else { completion(false) ; return }
                    
                    dispatchGroup.enter()
                    let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
                        if let error = error {
                            print(error)
                            completion(false)
                            dispatchGroup.leave()
                            return
                        }
                        
                        guard let data = data,
                            let image = UIImage(data: data)
                            else { completion(false) ; return }
                        
                        sharedPlace.photos?.append(image)
                        
                        dispatchGroup.leave()
                    }
                    dataTask.resume()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(true)
        }
    }
}
