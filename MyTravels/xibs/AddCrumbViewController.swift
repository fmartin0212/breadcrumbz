//
//  AddCrumbViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 2/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class AddCrumbViewController: UIViewController, ScrollableViewController {
    
    // MARK: - Properties
    
    // Scrollable View Controller
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    var selectedTextField: UITextField?
    var selectedTextView: UITextView?
    
    @IBOutlet weak var photoBackdropView: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var crumbPhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addPhotoButtonTopConstraint: NSLayoutConstraint!
    
    var trip: TripObject?
    var photoData: Data?
    let imagePickerController = UIImagePickerController()
    let pickerView = UIPickerView()
    var type: String?
    var fromSearchVC = false
    var photos: [Data] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatViews()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        pickerView.dataSource = self
        pickerView.delegate = self
        nameTextField.delegate = self
        typeTextField.delegate = self
        addressTextField.delegate = self
        commentsTextView.delegate = self
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            self.adjustScrollView(keyboardFrame: keyboardFrame!, bottomConstraint: self.saveButtonBottomConstraint)
            self.selectedTextField = nil
            self.selectedTextView = nil
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardDidHide, object: nil, queue: .main) { (notification) in
            self.saveButtonBottomConstraint.constant = 100
            
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text,
            !name.isEmpty,
            let address = addressTextField.text,
            !address.isEmpty,
            let type = typeTextField.text,
            !type.isEmpty,
            let placeType = Place.types(rawValue: type.lowercased()),
            let trip = trip
        else { return }
        
        let place = PlaceController.shared.createNewPlaceWith(name: name, type: placeType, address: address, comments: commentsTextView.text, rating: 0, trip: trip as! Trip)
        PhotoController.shared.add(photos: self.photos, place: place)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension AddCrumbViewController {
    
    func formatViews() {
        
        // Text Fields
//        nameTextField.format()
//        addressTextField.format()
//        typeTextField.format()
        typeTextField.inputView = pickerView
        
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
        commentsTextView.format()

        // Photo image view
        photoImage.layer.cornerRadius = 6
        photoImage.clipsToBounds = true
    }
}


extension AddCrumbViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let photo = info[UIImagePickerControllerEditedImage] as? UIImage,
            let photoData = UIImageJPEGRepresentation(photo, 0.1)
            else { return }
        
        self.photoData = photoData
        self.photos = [photoData]
        self.crumbPhotoImageView.image = photo
        crumbPhotoImageView.isHidden = false
        
        photoImage.isHidden = true
//        addPhotoButtonTopConstraint.constant = 10
        contentView.layoutIfNeeded()
        addPhotoButton.setTitle("Change Photo", for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddCrumbViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "Restaurant"
        case 1:
            return "Lodging"
        case 2:
            return "Activity"
        default:
            return ""
        }
    }
}

extension AddCrumbViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var type = ""
        switch row {
        case 0:
            type = "Restaurant"
        case 1:
            type = "Lodging"
        case 2:
            type = "Activity"
        default:
            print("Something went wrong")
        }
        typeTextField.text = type
    }
}

extension AddCrumbViewController: UITextFieldDelegate {
    
    // Part of ScrollableViewController implementation
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if fromSearchVC {
            fromSearchVC = false
            return false
        }
        if textField.tag == 3 {
            let searchVC = UIStoryboard.main.instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
            searchVC.delegate = self
            present(searchVC, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}

extension AddCrumbViewController: SearchViewControllerDelegate {
    
    func set(address: String) {
        addressTextField.text = address
        fromSearchVC = true
    }
}

extension AddCrumbViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.selectedTextView = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.returnKeyType = .done
    }
    
}
