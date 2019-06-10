//
//  CacheManager.swift
//  MyTravels
//
//  Created by Frank Martin on 4/14/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class CacheManager {
    static let shared = CacheManager()
    
    let imageCache = NSCache<NSString, UIImage>()
    
    func addImage(path: String, image: UIImage) {
        imageCache.setObject(image, forKey: path as NSString)
    }
    
    func queryImageCache(path: String) -> UIImage? {
        let image = imageCache.object(forKey: path as NSString)
        return image
    }
}
