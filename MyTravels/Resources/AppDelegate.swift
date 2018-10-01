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
        
        InternalUserController.shared.createNewUserWith(firstName: "Frank", lastName: "Martin", email: "fmartin0212@gmail.com", password: "password") { (success) in
        let trip = Trip(name: "Test trip 1", location: "Location test", tripDescription: "Test trip Description", startDate: Date(), endDate: Date())
        TripController.shared.upload(trip: trip)
        }
        
        return true
    }
}

