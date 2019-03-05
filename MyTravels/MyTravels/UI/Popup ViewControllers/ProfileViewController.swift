//
//  ProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/19/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CloudKit
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lineView2: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let loggedInUser = InternalUserController.shared.loggedInUser {
            
            usernameLabel.text = loggedInUser.username
            nameLabel.text = "\(loggedInUser.firstName) \(loggedInUser.lastName ?? "")"
            
            if let photo = loggedInUser.photo {
                profilePictureButton.setBackgroundImage(photo, for: .normal)
                profilePictureButton.setImage(nil, for: .normal)
                
                profilePictureButton.clipsToBounds = true
                profilePictureButton.layer.cornerRadius = profilePictureButton.frame.width / 2
            }
            lineView1.formatLine()
            lineView2.formatLine()
        }
    }
        
    // MARK: - Actions
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
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
    
    func clearViews() {
        profilePictureButton.setBackgroundImage(UIImage(named:"ProfileTabBarButton_Unselected"), for: .normal)
        usernameLabel.text = ""
        nameLabel.text = ""
    }
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        let profilePicture = info[UIImagePickerControllerEditedImage] as? UIImage
        profilePictureButton.setBackgroundImage(profilePicture, for: .normal)
        profilePictureButton.setImage(nil, for: .normal)
        profilePictureButton.clipsToBounds = true
        profilePictureButton.layer.cornerRadius = 61
        profilePictureButton.backgroundColor = UIColor.clear
        picker.dismiss(animated: true) {
            // Present the loading view
            let loadingView = self.presentLoadingView()
            loadingView.loadingLabel.text = "Saving"
            
            guard let loggedInUser = InternalUserController.shared.loggedInUser,
                let updatedProfileImage = self.profilePictureButton.backgroundImage(for: .normal)
                else { return }
            
            InternalUserController.shared.saveProfilePhoto(photo: updatedProfileImage, for: loggedInUser) { (success) in
                if success {
                    NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
                    loadingView.removeFromSuperview()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
