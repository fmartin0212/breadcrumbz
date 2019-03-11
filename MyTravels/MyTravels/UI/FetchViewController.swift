//
//  FetchViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/10/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseAuth

class FetchViewController: UIViewController {
    
    var tripTabBarController: UITabBarController = {
//        let tripTabBarController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let tripTabBarController = UITabBarController()
        let myTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let sharedTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let myTripsItem = UITabBarItem(title: "My Trips", image: UIImage(named: "TripsTabBarIcon"), selectedImage: UIImage(named: "TripsTabBarIcon"))
        let sharedTripsItem = UITabBarItem(title: "Shared", image: UIImage(named: "TripsTabBarIcon"), selectedImage: UIImage(named: "TripsTabBarIcon"))
        tripTabBarController.tabBar.setItems([myTripsItem, sharedTripsItem], animated: true)
        tripTabBarController.viewControllers = [myTripListVC, sharedTripListVC]
        return tripTabBarController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        
        if UserDefaults.standard.value(forKey: "userSkippedSignUp") == nil {
            UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        }
        
        InternalUserController.shared.checkForLoggedInUser { (success) in
            if success {
                SharedTripsController.shared.fetchSharedTrips() { (success) in
                    if !success {
                        DispatchQueue.main.async {
                            UIApplication.shared.windows.first!.rootViewController = self.tripTabBarController
                            return
                        }
                    }
                    DispatchQueue.main.async {
                        UIApplication.shared.windows.first!.rootViewController = self.tripTabBarController
                    }
                }
            } else if !success && UserDefaults.standard.value(forKey: "userSkippedSignUp") as! Bool == false {
                DispatchQueue.main.async {
                    let onboardingVC = UIStoryboard.onboarding.instantiateInitialViewController()
                    UIApplication.shared.windows.first!.rootViewController = onboardingVC
                }
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.windows.first!.rootViewController = self.tripTabBarController
                }
            }
        }
    }
}

