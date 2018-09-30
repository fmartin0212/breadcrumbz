//
//  ProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/19/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CloudKit

class ProfileViewController: UIViewController {
    
    let profilePictureSetNotification = Notification.Name("profilePictureSet")

    @IBOutlet weak var overlayView: UIView!
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
        
        guard let loggedInUser = UserController.shared.loggedInUser
            else { return }
        
        profilePictureButton.setImage(nil, for: .normal)
    
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let loggedInUser = UserController.shared.loggedInUser,
            let updatedProfileImage = profilePictureButton.backgroundImage(for: .normal)
            else { return }
        
//        guard let record = CKRecord(user: loggedInUser) else { return }
//
//        CloudKitManager.shared.updateOperation(records: [record]) { (success) in
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: TripsListViewController.profilePictureUpdatedNotification, object: self)
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
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
            cell.textLabel?.text = loggedInUser.email
        case 1:
            cell.textLabel?.text = loggedInUser.firstName
        case 2:
            cell.textLabel?.text = loggedInUser.lastName
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
        
//        NotificationCenter.default.post()
    }

}
