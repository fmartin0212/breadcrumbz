//
//  AddTripViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/7/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

final class AddTripViewController: UIViewController, ScrollableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var nameLocOuterStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var startDayLabel: UILabel!
    @IBOutlet weak var startMonthTextField: UITextField!
    @IBOutlet weak var startDayOfWeekLabel: UILabel!
    
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var endDayLabel: UILabel!
    @IBOutlet weak var endMonthTextField: UITextField!
    @IBOutlet weak var endDayOfWeekLabel: UILabel!
    
    @IBAction func startTapGestureRecognizer(_ sender: Any) {
        startMonthTextField.becomeFirstResponder()
    }
    @IBAction func endTapGestureRecognizer(_ sender: Any) {
        endMonthTextField.becomeFirstResponder()
    }
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
    var selectedTextView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        locationTextField.delegate = self
        descriptionTextView.delegate = self
        startMonthTextField.delegate = self
        endMonthTextField.delegate = self
        
        startDatePicker.addTarget(self, action: #selector(setDate(sender:)), for: .valueChanged)
        startMonthTextField.tag = 8
        endDatePicker.addTarget(self, action: #selector(setDate(sender:)), for: .valueChanged)
        endMonthTextField.tag = 9
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            if self.selectedTextField?.tag == 8 || self.selectedTextField?.tag == 9 {
                self.saveBottomContraint.constant += keyboardFrame!.height
                self.view.layoutIfNeeded()
                self.scrollView.setContentOffset(CGPoint(x: self.contentView.frame.origin.x, y: (self.selectedTextField!.superview!.frame.origin.y - (self.selectedTextField!.superview!.frame.origin.y * 1 / 7))), animated: true)
                self.selectedTextField = nil
                return
            }
            self.adjustScrollView(keyboardFrame: keyboardFrame!, bottomConstraint: self.saveBottomContraint)
            self.selectedTextField = nil
            self.selectedTextView = nil
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardDidHide, object: nil, queue: .main) { (notification) in
            self.saveBottomContraint.constant = 100
            
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
        
        // Buttons
        saveButton.layer.cornerRadius = 12
        
        addPhotoButton.clipsToBounds = true
        addPhotoButton.layer.cornerRadius = 4
        
        // Text View
        descriptionTextView.format()
        
        // Views
        startDateView.layer.cornerRadius = 6
        startDateView.layer.borderColor = UIColor.gray.cgColor
        startDateView.layer.borderWidth = 0.3
        endDateView.layer.cornerRadius = 6
        endDateView.layer.borderColor = UIColor.gray.cgColor
        endDateView.layer.borderWidth = 0.3
        
        // Text Fields
        startMonthTextField.inputView = startDatePicker
        startMonthTextField.borderStyle = .none
        startMonthTextField.tintColor = UIColor.clear
        startMonthTextField.layer.borderWidth = 0
        endMonthTextField.inputView = endDatePicker
        endMonthTextField.borderStyle = .none
        endMonthTextField.tintColor = UIColor.clear
        endMonthTextField.layer.borderWidth = 0 
        
        // Date Picker
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
    }
    
    @objc func setDate(sender: UIDatePicker) {
        let date = sender.date
        let dateComponents = Calendar.current.dateComponents([.day, .month, .weekday], from: date)
        let day = "\(dateComponents.day!)"
        let dayOfWeek = Calendar.current.weekdaySymbols[dateComponents.weekday! - 1]
        let month = String(Calendar.current.monthSymbols[dateComponents.month! - 1].prefix(3))
        switch selectedTextField?.tag {
        case 8:
            startDayLabel.text = day
            startDayOfWeekLabel.text = dayOfWeek
            startMonthTextField.text = month
            startDate = date
        case 9:
            endDayLabel.text = day
            endDayOfWeekLabel.text = dayOfWeek
            endMonthTextField.text = month
            endDate = date
        default:
            return
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
        
//        if let photo = addPhotoButton.image,
//            let compressedImage = UIImageJPEGRepresentation(photo, 0.1) {
//
//            PhotoController.shared.add(photo: compressedImage, trip: newTrip)
//        }
        dismiss(animated: true, completion: nil)
    }
}

extension AddTripViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let editedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        addPhotoButton.setBackgroundImage(editedPhoto, for: .normal)
        addPhotoButton.imageView?.contentMode = .scaleAspectFit
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddTripViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 4 {
            descriptionTextView.becomeFirstResponder()
            return true
        } else {
            view.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
            return true
        }
    }
}

extension AddTripViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        selectedTextView = textView
        return true
    }
}
