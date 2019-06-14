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
                    Coordinator().presentMainTabBar()
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




