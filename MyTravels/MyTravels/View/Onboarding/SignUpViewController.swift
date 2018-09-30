//
//  SignUpViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/14/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        signUpButton.formatBlue()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        var frame = self.tableView.frame
        frame.size = self.tableView.contentSize
        self.tableView.frame = frame
    }

    // MARK: - Outlets
    @IBOutlet weak var skipButtonTapped: UIButton!

    // MARK: - Actions
    @IBAction func skipButtonTapped(_ sender: Any) {
        presentTripListVC()
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "userSkippedSignUp")
        createNewAccount()
    }
}

extension SignUpViewController {
    
    func createNewAccount() {
        
        let firstNameCellIndexPath = IndexPath(row: 0, section: 0)
        let firstNameCell = (tableView.cellForRow(at: firstNameCellIndexPath)) as! TextFieldTableViewCell
        guard let firstName = firstNameCell.entryTextField.text, !firstName.isEmpty else { return }
        
        let lastNameCellIndexPath = IndexPath(row: 1, section: 0)
        let lastNameCell = (tableView.cellForRow(at: lastNameCellIndexPath)) as! TextFieldTableViewCell
        guard let lastName = lastNameCell.entryTextField.text, !lastName.isEmpty else { return }
        
        let usernameCellIndexPath = IndexPath(row: 2, section: 0)
        let usernameCell = (tableView.cellForRow(at: usernameCellIndexPath)) as! TextFieldTableViewCell
        guard let username = usernameCell.entryTextField.text, !username.isEmpty else { return }
        
        guard let placeholderProfilePicture = UIImage(named: "user") else { return }
        let placeholderProfilePictureAsData = UIImagePNGRepresentation(placeholderProfilePicture)
        
//        UserController.shared.createNewUserWith(firstName: firstName, lastName: lastName, username: username, profilePicture: placeholderProfilePictureAsData) { (success) in
//            if success {
//                DispatchQueue.main.async {
//                    self.presentTripListVC()
//                }
//            }
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SignUpViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
        cell.entryTextField.returnKeyType = .next
        
        switch indexPath.row {
        case 0:
            cell.entryTextField.placeholder = "First name"
        case 1:
            cell.entryTextField.placeholder = "Last name"
        case 2:
            cell.entryTextField.placeholder = "Email"
        case 3:
            cell.entryTextField.placeholder = "Password"
        case 4:
            cell.entryTextField.placeholder = "Confirm Password"
            cell.entryTextField.returnKeyType = .done
        case 5:
            cell.entryTextField.isHidden = true
        default:
            break
        }
        
        cell.entryTextField.tag = indexPath.row
        cell.entryTextField.delegate = self
        
        return cell
    }
}

extension SignUpViewController: UITableViewDelegate {
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let passwordTextField = tableView.viewWithTag(3) as? UITextField else { return false }
        if textField.tag == 4 {
            if passwordTextField.text == textField.text {
                createNewAccount()
            } else {
                // FIXME: - PRESENT ALERT CONTROLLER
            }
            return false
        }
        
        let nextResponderIndexPath = IndexPath(row: textField.tag + 1, section: 0)
        (tableView.cellForRow(at: nextResponderIndexPath) as! TextFieldTableViewCell).entryTextField.becomeFirstResponder()
        
        return true
    }
}
