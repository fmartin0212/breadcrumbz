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
                self.presentTripListVC()
           
            } else if !success && UserDefaults.standard.value(forKey: "userSkippedSignUp") as! Bool == false {
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let tripListNavigationController = storyboard.instantiateViewController(withIdentifier: "OnboardingPageVC")
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


