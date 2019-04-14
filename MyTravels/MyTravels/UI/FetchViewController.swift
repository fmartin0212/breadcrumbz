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
        let tripTabBarController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let myTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let myTripsNavigationController = UINavigationController(rootViewController: myTripListVC)
        let sharedTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let profileVC = UIStoryboard.profile.instantiateViewController(withIdentifier: "ProfileNavController")
        sharedTripListVC.state = .shared
        let mySharedTripsNavigationController = UINavigationController(rootViewController: sharedTripListVC)
        //        tripTabBarController.tabBar.setItems([myTripsItem, sharedTripsItem], animated: true)
        tripTabBarController.setViewControllers([myTripsNavigationController, mySharedTripsNavigationController, profileVC], animated: true)
        tripTabBarController.tabBar.items!.first!.title = "My Trips"
        tripTabBarController.tabBar.items!.first!.image = UIImage(named: "MyTrips")
        tripTabBarController.tabBar.items![1].title = "Shared"
        tripTabBarController.tabBar.items![1].image = UIImage(named: "Shared")
        tripTabBarController.tabBar.items![2].title = "Profile"
        tripTabBarController.tabBar.items![2].image = UIImage(named: "User")
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

