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
        let tripTabBarController = UITabBarController()
        let myTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let myTripsNavigationController = UINavigationController(rootViewController: myTripListVC)
        let sharedTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let profileVC = UIStoryboard.profile.instantiateViewController(withIdentifier: "ProfileNavController")
        sharedTripListVC.state = .shared
        let mySharedTripsNavigationController = UINavigationController(rootViewController: sharedTripListVC)
        tripTabBarController.setViewControllers([myTripsNavigationController, mySharedTripsNavigationController, profileVC], animated: true)
        tripTabBarController.tabBar.items!.first!.title = "My Trips"
        tripTabBarController.tabBar.items!.first!.image = UIImage(named: "MyTrips")
        tripTabBarController.tabBar.items![1].title = "Shared"
        tripTabBarController.tabBar.items![1].image = UIImage(named: "Shared")
        tripTabBarController.tabBar.items![2].title = "Profile"
        tripTabBarController.tabBar.items![2].image = UIImage(named: "User")
        tripTabBarController.tabBar.backgroundColor = UIColor.white
        return tripTabBarController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1)
        UITabBar.appearance().tintColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 16)!], for: .normal)
        UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        if UserDefaults.standard.value(forKey: "userSkippedSignUp") == nil {
            UserDefaults.standard.setValue(true, forKey: "userSkippedSignUp")
        }
        
        InternalUserController.shared.checkForLoggedInUser { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    UIApplication.shared.windows.first!.rootViewController = self.tripTabBarController
                    return
                }
            case .failure(_):
                if UserDefaults.standard.bool(forKey: "userSkippedSignUp") == false {
                    DispatchQueue.main.async {
                        let onboardingVC = UIStoryboard.onboarding.instantiateInitialViewController()
                        UIApplication.shared.windows.first!.rootViewController = onboardingVC
                    }
                }
            }
        }
    }
}




