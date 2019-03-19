//
//  ProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/19/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Properties
    
    // Outlets
    @IBOutlet weak var tripsLoggedLabel: UILabel!
    @IBOutlet weak var tripsSharedLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        title = "Profile"
        let basicCell = UINib(nibName: "BasicTableViewCell", bundle: nil)
        tableView.register(basicCell, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
        
    // MARK: - Actions
//    
//    @IBAction func profileButtonTapped(_ sender: Any) {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.allowsEditing = true
//        imagePickerController.delegate = self
//        present(imagePickerController, animated: true, completion: nil)
//    }
    
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
    
    func updateViews() {
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return }
        
        usernameLabel.text = loggedInUser.username
        nameLabel.text = loggedInUser.firstName
        tripsLoggedLabel.text = "\(TripController.shared.trips.count)"
        tripsSharedLabel.text = "\(loggedInUser.sharedTripIDs?.count ?? 0)"
        
        if let photo = loggedInUser.photo {
            profilePhoto.clipsToBounds = true
            profilePhoto.layer.cornerRadius = profilePhoto.frame.width / 2
            profilePhoto.contentMode = .scaleAspectFill
            profilePhoto.image = photo
            
        }
    }
    
    func clearViews() {
//        profilePhoto.setBackgroundImage(UIImage(named:"ProfileTabBarButton_Unselected"), for: .normal)
        usernameLabel.text = ""
        nameLabel.text = ""
    }
}

//extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        let profilePicture = info[UIImagePickerControllerEditedImage] as? UIImage
//        profilePictureButton.setBackgroundImage(profilePicture, for: .normal)
//        profilePictureButton.setImage(nil, for: .normal)
//        profilePictureButton.clipsToBounds = true
//        profilePictureButton.layer.cornerRadius = 61
//        profilePictureButton.backgroundColor = UIColor.clear
//        picker.dismiss(animated: true) {
//            // Present the loading view
//            let loadingView = self.presentLoadingView()
//            loadingView.loadingLabel.text = "Saving"
//
//            guard let loggedInUser = InternalUserController.shared.loggedInUser,
//                let updatedProfileImage = self.profilePictureButton.backgroundImage(for: .normal)
//                else { return }
//
//            InternalUserController.shared.saveProfilePhoto(photo: updatedProfileImage, for: loggedInUser) { (success) in
//                if success {
//                    NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
//                    loadingView.removeFromSuperview()
//                    self.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
//    }
//}

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BasicTableViewCell else { return UITableViewCell() }
     
        switch indexPath.row {
        case 0:
            cell.basicLabel.text = "Edit Profile"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.basicLabel.text = "Location"
            cell.basicSwitch.isHidden = false
        case 2:
            cell.basicLabel.text = "Push Notifications"
            cell.basicSwitch.isHidden = false
        case 3:
            cell.basicLabel.text = "Terms of Service"
            cell.accessoryType = .disclosureIndicator
        case 4:
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
            let editProfileVC = UIStoryboard.profile.instantiateViewController(withIdentifier: "EditProfile")
            navigationController?.pushViewController(editProfileVC, animated: true)
            default:
            return
        }
    }
}
