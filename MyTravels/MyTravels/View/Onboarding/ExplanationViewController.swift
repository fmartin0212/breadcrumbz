//
//  ExplanationViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class ExplanationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "userSkippedSignUp")
        presentTripListVC()
    }
}
