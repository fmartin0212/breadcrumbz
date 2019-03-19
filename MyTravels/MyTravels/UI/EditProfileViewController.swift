//
//  EditProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 3/18/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    // Scrollable View Controller
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    var selectedTextField: UITextField?
    var selectedTextView: UITextView?
    
    // Outlets
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var nameTextField: FMTextField!
    @IBOutlet weak var usernameTextField: FMTextField!
    @IBOutlet weak var emailTextField: FMTextField!
    @IBOutlet weak var changePasswordTextField: FMTextField!
    @IBOutlet weak var confirmPasswordTextFIeld: FMTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
    }
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let profilePicture = info[UIImagePickerControllerEditedImage] as? UIImage
        
        addPhotoButton.setImage(profilePicture, for: .normal)
        addPhotoButton.clipsToBounds = true
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
        picker.dismiss(animated: true) {
            // Present the loading view
            let loadingView = self.presentLoadingView()
            loadingView.loadingLabel.text = "Saving"
            
            guard let loggedInUser = InternalUserController.shared.loggedInUser
                else { return }
            
            InternalUserController.shared.saveProfilePhoto(photo: profilePicture!, for: loggedInUser) { (success) in
                if success {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(Notification(name: Notification.Name("profilePictureUpdatedNotification")))
                        loadingView.removeFromSuperview()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
