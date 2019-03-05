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
                        print("trips not fetched")
//                        self.presentTripListVC()
                        let tripListNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController")
                        UIApplication.shared.windows.first!.rootViewController = tripListNavigationController
                        return
                    }
                    DispatchQueue.main.async {
                        let tripListNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController")
                        UIApplication.shared.windows.first!.rootViewController = tripListNavigationController
                    }
                }
            } else if !success && UserDefaults.standard.value(forKey: "userSkippedSignUp") as! Bool == false {
                DispatchQueue.main.async {
                        let onboardingVC = UIStoryboard.onboarding.instantiateInitialViewController()
                        UIApplication.shared.windows.first!.rootViewController = onboardingVC
                }
            } else {
                DispatchQueue.main.async {
//                    self.presentTripListVC()
                    let tripListNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController")
                    UIApplication.shared.windows.first!.rootViewController = tripListNavigationController
                }
            }
        }
    }
}

