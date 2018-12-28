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
    
    let profilePictureSetNotification = Notification.Name("profilePictureSet")

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setPropertiesFor(overlayView: overlayView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        profilePictureButton.clipsToBounds = true
        profilePictureButton.layer.cornerRadius = 61
        
        if let loggedInUserPhoto = InternalUserController.shared.loggedInUser?.photo {
            profilePictureButton.setBackgroundImage(loggedInUserPhoto, for: .normal)
            profilePictureButton.setImage(nil, for: .normal)
        }
        
        if let _ = InternalUserController.shared.loggedInUser {
            logOutButton.isHidden = false
        }
    }
    
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
                self.dismiss(animated: true, completion: nil)                
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmationAlertController.addAction(logOutAction)
        confirmationAlertController.addAction(cancelAction)
        
        self.present(confirmationAlertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // Present the loading view
        let loadingView = self.presentLoadingView()
        loadingView.loadingLabel.text = "Saving"
        
        guard let loggedInUser = InternalUserController.shared.loggedInUser,
            let updatedProfileImage = profilePictureButton.backgroundImage(for: .normal)
            else { return }
        
        InternalUserController.shared.saveProfilePhoto(photo: updatedProfileImage, for: loggedInUser) { (success) in
            if success {
                NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
                loadingView.removeFromSuperview()
                self.dismiss(animated: true, completion: nil)
            }
        }
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
        
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = loggedInUser.username
        case 1:
            cell.textLabel?.text = loggedInUser.firstName
        case 2:
            cell.textLabel?.text = loggedInUser.lastName ?? ""
        default:
            break
        }
        return cell
    }
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerLabel = UILabel()
        headerLabel.backgroundColor = UIColor.white
        headerLabel.font = UIFont(name: "AvenirNext", size: 15)
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

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        let profilePicture = info[UIImagePickerControllerEditedImage] as? UIImage
        profilePictureButton.setBackgroundImage(profilePicture, for: .normal)
        profilePictureButton.setImage(nil, for: .normal)
        profilePictureButton.backgroundColor = UIColor.clear
        picker.dismiss(animated: true) {
            self.saveButton.isHidden = false
        }
    }
}
