//
//  SignUpVC.swift
//  MyTravels
//
//  Created by Frank Martin on 2/27/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {

    @IBOutlet weak var nameTextField: FMTextField!
    @IBOutlet weak var emailTextField: FMTextField!
    @IBOutlet weak var usernameTextField: FMTextField!
    @IBOutlet weak var passwordTextField: FMTextField!
    @IBOutlet weak var confirmPasswordTextField: FMTextField!
    @IBOutlet weak var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getStartedButtonTapped(_ sender: Any) {
    }
    
}
