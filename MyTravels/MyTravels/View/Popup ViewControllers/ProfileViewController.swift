//
//  ProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/19/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPropertiesFor(overlayView: overlayView)
        
        tableView.dataSource = self
        tableView.delegate = self
        profilePictureButton.clipsToBounds = true
        profilePictureButton.layer.cornerRadius = 61
    }
    
    @IBAction func tapGestureRecognized(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileDetailCell", for: indexPath)
        
        guard let loggedInUser = UserController.shared.loggedInUser else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = loggedInUser.firstName
        case 1:
            cell.textLabel?.text = loggedInUser.lastName
        case 2:
            cell.textLabel?.text = loggedInUser.username
        default:
            break
        }
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "AvenirNext", size: 18)
        headerLabel.textColor = UIColor.gray
        
        switch section {
        case 0:
            headerLabel.text = "   Username"
        case 1:
            headerLabel.text = "   First name"
        case 2:
            headerLabel.text = "   Last name"
        default:
            break
        }
        return headerLabel
    }
}
