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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var nameLocOuterStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addPhotoButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoBackdropView: UIView!
    @IBOutlet weak var photoIcon: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var largeLineView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
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
    var selectedTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        locationTextField.delegate = self
        startDateTextField.delegate = self
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            let keyboardHeight = keyboardFrame?.height
            self.saveBottomContraint.constant = 100 + keyboardHeight!
            self.view.layoutIfNeeded()
       
            var point = CGPoint(x: 0, y: 0)
            
//            switch self.selectedTextField!.tag {
//            case 1:
//                point = CGPoint(x: self.contentView.frame.origin.x, y: self.nameLocOuterStackView.frame.origin.y)
//            default:
//                print("adsf")
//            }
//            self.scrollView.setContentOffset(point, animated: true)

        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardDidHide, object: nil, queue: .main) { (notification) in
            self.saveBottomContraint.constant = 100
            
        }
        
        setupViews()
        nameTextField.addKeyboardDone(targetVC: self, selector: #selector(dismissKeyboard))
        locationTextField.addKeyboardDone(targetVC: self, selector: #selector(dismissKeyboard))
        startDateTextField.addKeyboardDone(targetVC: self, selector: #selector(dismissKeyboard))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveNewTrip()
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveBarButtonItemTapped(_ sender: Any) {
        saveNewTrip()
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
        photoBackdropView.layer.shadowColor = #colorLiteral(red: 1, green: 0.4002141953, blue: 0.372333765, alpha: 1)
        photoBackdropView.layer.shadowRadius = 10
        photoBackdropView.layer.shadowOpacity = 1.0
        photoBackdropView.layer.shadowOffset = CGSize(width: 0, height: 0)
        
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
    
    @objc func dismissKeyboard() {
        contentView.endEditing(true)
    }
    
    func saveNewTrip() {
        guard let name = nameTextField.text, !name.isEmpty,
            let location = locationTextField.text, !location.isEmpty,
            let startDate = startDate,
            let endDate = endDate
            else { return }
        
        let newTrip = TripController.shared.createTripWith(name: name, location: location, tripDescription: descriptionTextView.text, startDate: startDate, endDate: endDate)
        
        if let photo = photoImageView.image,
            let compressedImage = UIImageJPEGRepresentation(photo, 0.1) {
            
            PhotoController.shared.add(photo: compressedImage, trip: newTrip)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension AddTripViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let editedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        photoImageView.image = editedPhoto
        photoImageView.isHidden = false
        
        photoIcon.isHidden = true
        addPhotoButtonTopConstraint.constant = 10
        contentView.layoutIfNeeded()
        addPhotoButton.setTitle("Change Photo", for: .normal)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddTripViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      
//        var point = CGPoint(x: 0, y: 0)
//        switch textField.tag {
//        case 1:
//            point = CGPoint(x: contentView.frame.origin.x, y: nameLocOuterStackView.frame.maxY - nameLocOuterStackView.frame.height)
//        default:
//            print("adsf")
//        }
//        scrollView.setContentOffset(point, animated: true)
        selectedTextField = textField
    }
}

//(0, (textField.superview.frame.origin.y + (textField.frame.origin.y)))
