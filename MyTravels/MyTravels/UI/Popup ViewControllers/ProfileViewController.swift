//
//  ProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/19/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {

    // MARK: - Properties
    
    // Outlets
    @IBOutlet weak var tripsLoggedLabel: UILabel!
    @IBOutlet weak var tripsSharedLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var photoBackgroundView: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatViews()
        updateViews()
        title = "Profile"
        let basicCell = UINib(nibName: "BasicTableViewCell", bundle: nil)
        tableView.register(basicCell, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        let confirmationAlertController = UIAlertController(title: "Log out", message: "Are you sure you would like to log out?", preferredStyle: .alert)
        
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { (_) in
            InternalUserController.shared.logOut()
            NotificationCenter.default.post(name: Constants.sharedTripsReceivedNotif, object: nil)
            DispatchQueue.main.async {
                self.clearViews()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmationAlertController.addAction(logOutAction)
        confirmationAlertController.addAction(cancelAction)
        
        self.present(confirmationAlertController, animated: true, completion: nil)
    }
}

extension ProfileViewController {
    
    func formatViews() {
        photoBackgroundView.layer.cornerRadius = photoBackgroundView.frame.width / 2
        photoBackgroundView.layer.borderColor = UIColor.black.cgColor
        photoBackgroundView.layer.borderWidth = 1
    }
    
    func updateViews() {
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return }
        
        usernameLabel.text = loggedInUser.username
        nameLabel.text = loggedInUser.firstName
        tripsLoggedLabel.text = "\(TripController.shared.trips.count)"
        tripsSharedLabel.text = "\(loggedInUser.sharedTripIDs?.count ?? 0)"
        
        guard let loggedInUserPhotoUID = loggedInUser.photoURL else { return }
        PhotoController.shared.fetchPhoto(withPath: loggedInUserPhotoUID, completion: { [weak self] (result) in
            switch result {
            case .success(let photo):
                DispatchQueue.main.async {
                    self?.profilePhoto.clipsToBounds = true
                    self?.profilePhoto.layer.cornerRadius = (self?.profilePhoto.frame.width)! / 2
                    self?.profilePhoto.contentMode = .scaleAspectFill
                    self?.profilePhoto.image = photo
                    self?.profilePhoto.image = photo
                    self?.photoBackgroundView.layer.borderWidth = 0
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func clearViews() {
        profilePhoto.image = UIImage(named:"User")
        profilePhoto.contentMode = .center
        usernameLabel.text = ""
        nameLabel.text = ""
    }
}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BasicTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.basicLabel.text = "Edit Profile"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.basicLabel.text = "Location"
            cell.basicSwitch.isHidden = false
//        case 2:
//            cell.basicLabel.text = "Push Notifications"
//            cell.basicSwitch.isHidden = false
        case 2:
            cell.basicLabel.text = "Terms of Service"
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.basicLabel.text = "Privacy Policy"
            cell.accessoryType = .disclosureIndicator
        default:
            print("Something went wrong")
        }
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            guard let editProfileVC = UIStoryboard.profile.instantiateViewController(withIdentifier: "EditProfile") as? EditProfileViewController else { return }
            if let image = profilePhoto.image {
                editProfileVC.profileImage = image
            }
            navigationController?.pushViewController(editProfileVC, animated: true)
        case 2:
            let genericScrollingLabelVC = GenericScrollingLabelViewController(legalInfo: .termsOfService, nibName: "GenericScrollingLabelVC")
            navigationController?.pushViewController(genericScrollingLabelVC, animated: true)
        case 3:
             let genericScrollingLabelVC = GenericScrollingLabelViewController(legalInfo: .privacyPolicy, nibName: "GenericScrollingLabelVC")
            navigationController?.pushViewController(genericScrollingLabelVC, animated: true)
        default:
            return
        }
    }
}
