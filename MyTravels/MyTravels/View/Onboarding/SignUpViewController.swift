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
        
        signUpButton.formatBlue()

    }
    // MARK: - Outlets
    @IBOutlet weak var skipButtonTapped: UIButton!
}

extension SignUpViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SignUpViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath) as? TextFieldTableViewCell else { return UITableViewCell() }
        switch indexPath.row {
        case 0:
            cell.entryTextField.placeholder = "First name"
            cell.entryTextField.returnKeyType = .next
        case 1:
            cell.entryTextField.placeholder = "Last name"
            cell.entryTextField.returnKeyType = .next
        case 2:
            cell.entryTextField.placeholder = "Username"
            cell.entryTextField.returnKeyType = .done
        default:
            break
        }
        return cell
    }
}

extension SignUpViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension SignUpViewController: 
