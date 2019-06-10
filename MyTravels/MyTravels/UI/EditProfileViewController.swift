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
    var profileImage: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTextFields.forEach { $0.delegate = self }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            self?.adjustScrollView(keyboardFrame: keyboardFrame!)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] (notification) in
            self?.scrollView.contentInset = UIEdgeInsets.zero
        }
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.width / 2
        addPhotoButton.clipsToBounds = true
        updateViews()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text,
            !name.isEmpty,
            let username = usernameTextField.text,
            !username.isEmpty,
            // FIXME: - Present alert controller
            let loggedInUser = InternalUserController.shared.loggedInUser
            else { return }
        
        let updateFieldsAndCriteria = ["firstName": name, "username" : username]
        let loadingView = self.enableLoadingState()
        FirestoreService().update(object: loggedInUser, fieldsAndCriteria: updateFieldsAndCriteria, with: .update) { [weak self] (result) in
            self?.disableLoadingState(loadingView)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func updateViews() {
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { return }
        nameTextField.text = loggedInUser.firstName
        usernameTextField.text = loggedInUser.username
        emailTextField.text = loggedInUser.email
        guard let profileImage = profileImage else { return }
        updateAndFormatImageView(with: profileImage)
    }
    
    func updateAndFormatImageView(with image: UIImage) {
        addPhotoButton.contentMode = .scaleAspectFit
        addPhotoButton.setImage(image, for: .normal)
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
        picker.dismiss(animated: true) { [weak self] in
            // Present the loading view
            guard let loadingView = self?.enableLoadingState() else { return }            
            guard let loggedInUser = InternalUserController.shared.loggedInUser
                else { self?.disableLoadingState(loadingView) ; return }
            
            if let profileImage = self?.profileImage {
                let fmImage = FMImage(image: profileImage)
                FirebaseStorageService().delete(object: fmImage, completion: { (result) in
                    switch result {
                    case .success(_):
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            }
            InternalUserController.shared.saveProfilePhoto(photo: profilePicture!, for: loggedInUser) { [weak self] (result) in
                switch result {
                case .failure(_):
                    self?.presentStandardAlertController(withTitle: "Something went wrong", message: FireError.generic.rawValue)
                case .success(_):
                    DispatchQueue.main.async {
                        self?.disableLoadingState(loadingView)
                        self?.dismiss(animated: true, completion: nil)
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
