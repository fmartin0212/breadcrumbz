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

    let window = UIWindow(frame: UIScreen.main.bounds)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //rRRRASJMaVPHpV8qSVNqRni7M0q2
        FirebaseManager.fetch(uuid: nil, atChildKey: "username", withQuery: "fmartin0212", completion: { (user: InternalUser?) in
            print("adsf")
        })
        
        let fetchViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "fetchVC")
        window.rootViewController = fetchViewController
        window.makeKeyAndVisible()
        return true
    }
}

