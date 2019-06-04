//
//  SignUpVC.swift
//  MyTravels
//
//  Created by Frank Martin on 2/27/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bySigningLabel: UILabel!
    @IBOutlet weak var termsAndPrivacyStackView: UIStackView!
    @IBOutlet var allTextfields: [FMTextField]!
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: FMTextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: FMTextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameTextField: FMTextField!
    @IBOutlet weak var usernameStackView: UIStackView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: FMTextField!
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTextField: FMTextField!
    @IBOutlet weak var confirmPasswordStackView: UIStackView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var logInSignUpButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var signUpButtonTopConstraint: NSLayoutConstraint!
    var state: State = .signUp {
        didSet {
            updateViews()
        }
    }
    var isOnboarding = true
    lazy var loginButtonTopConstraint: NSLayoutConstraint = {
        NSLayoutConstraint(item: self.submitButton as Any, attribute: .top, relatedBy: .equal, toItem: self.stackView, attribute: .bottom, multiplier: 1.0, constant: 12)
    }()
    var signUpButtonTopConstraintPersister: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButtonTopConstraintPersister = signUpButtonTopConstraint
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Constants.viewWillAppearForVC, object: nil, userInfo: ["viewController": self])
    }
    
    @IBAction func getStartedButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.nameLabel.isHidden = false
            self.nameTextField.isHidden = false
            self.emailLabel.isHidden = false
            self.emailTextField.isHidden = false
        }
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        switch state {
        case .logIn :
            login()
        case .signUp:
            signUp()
        default:
            return
        }
    }
    
    @IBAction func logInSignUpButtonTapped(_ sender: Any) {
        switch state {
        case .logIn:
            state = .signUp
        case .signUp:
            state = .logIn
        default:
            return
        }
    }
    
    func updateViews() {
        switch state {
        case .logIn:
            UIView.animate(withDuration: 0.25) {
                self.nameTextField.keyboardType = .emailAddress
                self.emailTextField.textContentType = .password
                self.emailTextField.isSecureTextEntry = true
                self.usernameStackView.isHidden = true
                self.passwordStackView.isHidden = true
                self.confirmPasswordStackView.isHidden = true
                self.bySigningLabel.isHidden = true
                self.termsAndPrivacyStackView.isHidden = true
                self.signUpButtonTopConstraint.isActive = false
                self.signUpButtonTopConstraintPersister?.isActive = false
                self.loginButtonTopConstraint.isActive = true
                
                self.view.layoutIfNeeded()
            }
            self.nameLabel.text = "Email"
            self.emailLabel.text = "Password"
            self.submitButton.setTitle("Log In", for: .normal)
            logInSignUpButton.setTitle("Sign Up", for: .normal)
         
        case .signUp:
            UIView.animate(withDuration: 0.25) {
                self.nameTextField.keyboardType = .default
                self.emailTextField.textContentType = .emailAddress
                self.emailTextField.isSecureTextEntry = false
                self.usernameStackView.isHidden = false
                self.passwordStackView.isHidden = false
                self.confirmPasswordStackView.isHidden = false
                self.bySigningLabel.isHidden = false
                self.termsAndPrivacyStackView.isHidden = false
                self.signUpButtonTopConstraintPersister?.isActive = true
                self.loginButtonTopConstraint.isActive = false
                self.view.layoutIfNeeded()
            }
            self.nameLabel.text = "Name"
            self.emailLabel.text = "Email"
            self.submitButton.setTitle("Get Started", for: .normal)
            logInSignUpButton.setTitle("Log In", for: .normal)
        default:
            return
        }
        allTextfields.forEach { $0.text = "" }
    }
    
    func login() {
        guard let email = nameTextField.text,
            !email.isEmpty,
            let password = emailTextField.text,
            !password.isEmpty
            else { return }
        
        let loadingView = enableLoadingState()
        InternalUserController.shared.login(withEmail: email, password: password) { [weak self] (result) in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.disableLoadingState(loadingView)
                    self?.presentStandardAlertController(withTitle: "Oops!", message: error.rawValue)
                }
            case .success(_):
                DispatchQueue.main.async {
                    self?.disableLoadingState(loadingView)
                    if self?.isOnboarding == false {
                        NotificationCenter.default.post(name: Constants.userLoggedInNotif, object: nil)
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        let tabBarController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
                        let tripListVC = ((tabBarController?.customizableViewControllers?.first! as! UINavigationController).viewControllers.first!) as! TripsListViewController
                        //                        tripListVC.fromSignUpVC = true
                        self?.present(tabBarController!, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func signUp() {
        guard let name = nameTextField.text,
            !name.isEmpty,
            let email = emailTextField.text,
            !email.isEmpty,
            let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let confirmPassword = confirmPasswordTextField.text,
            !confirmPassword.isEmpty
            else { return }
        
        if password == confirmPassword {
            let loadingView = self.enableLoadingState()            
            InternalUserController.shared.createNewUserWith(firstName: name, lastName: "", username: username, email: email, password: password) { (result) in
                
                switch result {
                case .failure(let error):
                    self.disableLoadingState(loadingView)
                    self.presentStandardAlertController(withTitle: "Oops!", message: error.rawValue)
                case .success(_):
                    DispatchQueue.main.async {
                        self.disableLoadingState(loadingView)
                        if self.isOnboarding == false {
                            NotificationCenter.default.post(name: Constants.userLoggedInNotif, object: nil)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                         let tabBarController = UIStoryboard.main.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
                        self.present(tabBarController!, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            self.presentStandardAlertController(withTitle: "Oops!", message: "Your passwords do not match -- please re-enter your passwords")
        }
    }
}

enum State: Int {
    case logIn
    case signUp
    case managed
    case shared
    case add
    case edit
}
