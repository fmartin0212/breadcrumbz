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

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let ref = FirebaseManager.ref.child("User").child("fmartjn0212").child("participantTripIDs")
        FirebaseManager.fetch(from: ref) { (snapshot) in
            guard let participantTripIDDictionaries = snapshot.value as? [String : [String : String]] else { return }
            
            for (_, value) in participantTripIDDictionaries {
                let ref = FirebaseManager.ref.child("Trip").child(value["tripID"]!)
                FirebaseManager.fetch(from: ref, completion: { (snapshot) in
                    print(snapshot)
                })
            }
        }
        
        return true
    }
}

