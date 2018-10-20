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
        
        let dispatchGroup  = DispatchGroup()
        
        var places: [SharedPlace] = []
        
        for (_, value) in placesDictionary {
            
            guard let sharedPlace = SharedPlace(dictionary: value) else { completion([]) ; return }
            
            var placeImages: [UIImage] = []
            
            if let photoURLs = sharedPlace.photoURLs {
                for urlAsString in photoURLs {
                    
                    dispatchGroup.enter()
                    
                    guard let url = URL(string: urlAsString) else { completion([]) ; return }
  
                    let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
                        if let error = error {
                            print(error)
                            completion([])
                            dispatchGroup.leave()
                            return
                        }
                        
                        guard let data = data,
                            let image = UIImage(data: data)
                            else { completion([]) ; return }
                       
                        placeImages.append(image)
                     
                        dispatchGroup.leave()
                    }
                    dataTask.resume()
                }
            }
            places.append(sharedPlace)
        }
        
        dispatchGroup.notify(queue: .main, execute: {
            completion(places)
        })
    }
}
