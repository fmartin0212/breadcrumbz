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
        
//        try? Auth.auth().signOut()

        UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        
        if UserDefaults.standard.value(forKey: "userSkippedSignUp") == nil {
            UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        }
        
        InternalUserController.shared.checkForLoggedInUser { (success) in
            if success {
                SharedTripsController.shared.fetchSharedTrips() { (success) in
                    if !success {
                        print("trips not fetched")
                        self.presentTripListVC()
                        return
                    }
                    DispatchQueue.main.async {
                        self.presentTripListVC()
                    }
                }
            } else if !success && UserDefaults.standard.value(forKey: "userSkippedSignUp") as! Bool == false {
                let tripListNavigationController = UIStoryboard.main.instantiateViewController(withIdentifier: "OnboardingPageVC")
                DispatchQueue.main.async {
                    self.present(tripListNavigationController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.presentTripListVC()
                }
            }
        }
    }
}


