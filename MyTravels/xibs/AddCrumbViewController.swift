//
//  AddCrumbViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 2/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class AddCrumbViewController: UIViewController {

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
    
    var trip: Trip?
    var photoData: Data?
    let imagePickerController = UIImagePickerController()
    let pickerView = UIPickerView()
    var type: String?
    
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
        pickerView.dataSource = self
        pickerView.delegate = self

    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text,
            !name.isEmpty,
            let location = addressTextField.text else { return }
        
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
        nameTextField.format()
        addressTextField.format()
        typeTextField.format()
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
        self.crumbPhotoImageView.image = photo
        
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
