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
//        Auth.auth().signIn(withEmail: "fmartjn0212@gmail.com", password: "Spaceship11!") { (user, error) in
//            print(user?.displayName)
//        }
        
//        try? Auth.auth().signOut()
//        let ref = FirebaseManager.ref.child(InternalUserController.shared.loggedInUser!.username).child("participants")
//        FirebaseManager.fetch(from: <#T##DatabaseReference#>, completion: <#T##(DataSnapshot) -> Void#>)
        
         UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        
        
        
        if UserDefaults.standard.value(forKey: "userSkippedSignUp") == nil {
            UserDefaults.standard.setValue(false, forKey: "userSkippedSignUp")
        }
        
        InternalUserController.shared.checkForLoggedInUser { (success) in
            if success {
                SharedTripsController.shared.fetchSharedTrips() { (success) in
                    if !success {
                        print("trips not fetched")
                    }
                    self.presentTripListVC()
                }
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


