//
//  AddTripViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/7/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

final class AddTripViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addPhotoButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoBackdropView: UIView!
    @IBOutlet weak var photoIcon: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var largeLineView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var startDateLineView: UIView!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var endDateLineView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Constants & Variables
    
    var startDatePicker = UIDatePicker()
    var endDatePicker = UIDatePicker()
    var startDate: Date? {
        didSet {
            endDatePicker.minimumDate = startDate
            endDate = startDate
        }
    }
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardDidShow, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            let keyboardHeight = keyboardFrame?.height
            print(self.contentView.frame.height)
            self.contentView.frame = CGRect(x: self.contentView.frame.origin.x, y: self.contentView.frame.origin.y, width: self.contentView.frame.width, height: self.contentView.frame.height + keyboardHeight!)
            print(self.contentView.frame.height)
        }
        
        setupViews()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        
    }
}

extension AddTripViewController {
    
    /// Sets up the views for the AddTripViewController.
    func setupViews() {
        
        // Line views
        largeLineView.formatLine()
        startDateLineView.formatLine()
        endDateLineView.formatLine()
        
        // Text Fields
        nameTextField.format()
        locationTextField.format()
        
        // Photo backdrop
        photoBackdropView.layer.cornerRadius = photoBackdropView.frame.width / 2
        photoBackdropView.clipsToBounds = true
        
        // Buttons
        addPhotoButton.addBorder(with: #colorLiteral(red: 1, green: 0.4002141953, blue: 0.372333765, alpha: 1), andWidth: 4)
        saveButton.layer.cornerRadius = 12
        
        // Text View
        descriptionTextView.format()
        
        // Photo image view
        photoImageView.layer.cornerRadius = 6
        photoImageView.clipsToBounds = true
    
        
        // Date Pickers
        startDateTextField.inputView = startDatePicker
        startDatePicker.datePickerMode = .date
        startDatePicker.tag = 1
        startDatePicker.addTarget(self, action: #selector(setDate(sender:)), for: .valueChanged)

        endDateTextField.inputView = endDatePicker
        endDatePicker.datePickerMode = .date
        endDatePicker.tag = 2
        endDatePicker.addTarget(self, action: #selector(setDate(sender:)), for: .valueChanged)
    }
    
    @objc func setDate(sender: UIDatePicker) {
        switch sender.tag {
        case 1:
            startDate = sender.date
            startDateTextField.text = startDate?.shortWithFullYear()
        case 2:
            endDate = sender.date
            endDateTextField.text = endDate?.shortWithFullYear()
        default:
            print("Someting went wrong")
        }
    }
}

extension AddTripViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let editedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        photoImageView.image = editedPhoto
        photoImageView.isHidden = false
        view.bringSubview(toFront: photoImageView)
        
        photoIcon.isHidden = true
        addPhotoButtonTopConstraint.constant = addPhotoButton.frame.minY - photoImageView.frame.minY
        contentView.layoutIfNeeded()
        addPhotoButton.setTitle("Change Photo", for: .normal)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
