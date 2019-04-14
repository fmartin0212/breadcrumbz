//
//  EditProfileViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 3/18/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, ScrollableViewController {
    
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
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var allTextFields: [FMTextField]!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTextFields.forEach { $0.delegate = self }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            self.adjustScrollView(keyboardFrame: keyboardFrame!)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.bottomConstraint.constant = 30
        }
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        let profilePicture = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        
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

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
