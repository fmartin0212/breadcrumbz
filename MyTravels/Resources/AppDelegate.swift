//
//  AppDelegate.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
// my change another change
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
//        FirebaseManager.fetch(uuid: "fU2HTSJ6YJQdmebaob6FhdhTitj1") { (user: InternalUser?) in
//            guard let user = user else { return }
//            var participantTripIDs = [String : Any]()
//            participantTripIDs = ["LU8EwrZLu6jY6L23c112" : true]
//
//            FirebaseManager.update(object: user, atChildren: ["participantTripIDs"], withValues: participantTripIDs) { (_) in
//                print("adsF")
//            }
//        }
        
        return true
    }
}

