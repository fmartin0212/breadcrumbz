//
//  FetchViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/10/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class FetchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserController.shared.fetchCurrentUser(completion: { (success) in
            if success {
            SharedTripsController.shared.fetchUsersPendingSharedTrips(completion: { (_) in
                SharedTripsController.shared.fetchAcceptedSharedTrips(completion: { (_) in
                    SharedTripsController.shared.fetchPlacesForSharedTrips(completion: { (_) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let tripListNavigationController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                        DispatchQueue.main.async {
                            self.present(tripListNavigationController, animated: true, completion: nil)
                        }
                    })
                })
            })
            } else {
                let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let tripListNavigationController = storyboard.instantiateViewController(withIdentifier: "OnboardingPageVC")
                DispatchQueue.main.async {
                    self.present(tripListNavigationController, animated: true, completion: nil)
                }
            }
        })
    }
}


