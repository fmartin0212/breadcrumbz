//
//  CreateTripTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/4/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateTripTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var startDate: Date?
    var endDate: Date?
    var photo: Data?
    let imagePickerController = UIImagePickerController()
    
    // MARK: - Outlets

    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var tripLocationTextField: UITextField!
    @IBOutlet weak var tripDescriptionTextView: UITextView!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Delegates
        tripDescriptionTextView.delegate = self
        imagePickerController.delegate = self
        
        // Photo properties
        tripPhotoImageView.layer.cornerRadius = 4
        
        imagePickerController.allowsEditing = true
        
        // Trip description text view initial value
        tripDescriptionTextView.text = "Brief description (optional)"
        tripDescriptionTextView.textColor = #colorLiteral(red: 0.8037719131, green: 0.8036019206, blue: 0.8242246509, alpha: 1)
        
        cancelBarButtonItem.format()
        saveBarButtonItem.format()
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        // FIXME: - Add alert for name text field
        // Check to see if any required fields are empty, if so, present alertcontroller and jump out of function
        guard let tripStartLabel = tripStartDateLabel,
            let tripEndLabel = tripEndDateLabel
            else { return }
        
//        let textFields = [tripLocationTF, tripStartLabel, tripEndLabel]
        
        if tripLocationTextField.text?.isEmpty == true ||
            tripStartLabel.text == "Choose a start date" ||
            tripEndLabel.text == "Choose an end date"  {
//            missingFieldAlert(textFields: textFields)
            return
            
        }
        
        guard let name = tripNameTextField.text,
            let location = tripLocationTextField.text,
            var tripDescription = tripDescriptionTextView.text,
            let startDate = startDate,
            let endDate = endDate
            else { return }
        
        if tripDescription == "Brief description (optional)" {
            tripDescription = ""
        }
        
        let trip = TripController.shared.createTripWith(name: name, location: location, tripDescription: tripDescription, startDate: startDate, endDate: endDate)
        
        // Get newly created trip and add the photo to it
        guard let photo = photo else { dismiss(animated: true, completion: nil) ; return }
        PhotoController.shared.add(photo: photo, trip: trip)
    
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addPhotoGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Controller Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)


        picker.sourceType = .photoLibrary

        guard let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) else { return }
        picker.mediaTypes = availableMediaTypes
        guard let photo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
            else { print("photo nil") ; return }
        guard let photoAsData = photo.jpegData(compressionQuality: 0.1) else { return }
        self.photo = photoAsData
        
        self.tripPhotoImageView.image = photo
        self.tripPhotoImageView.contentMode = .scaleAspectFill
        
        dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Table View Delegate

extension CreateTripTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tripNameTextField.resignFirstResponder()
        tripLocationTextField.resignFirstResponder()
        tripDescriptionTextView.resignFirstResponder()
        
        // Create a reference to the ChooseDateViewController
        guard let chooseDateVC = UIStoryboard.main.instantiateViewController(withIdentifier: "chooseDateViewController") as? ChooseDateViewController else { return }
        
        switch indexPath.row {
            
        case 3:
            chooseDateVC.isEndDate = false
            chooseDateVC.delegate = self
            present(chooseDateVC, animated: true, completion: nil)
            return
            
        case 4:
            chooseDateVC.isEndDate = true
            chooseDateVC.delegate = self
            present(chooseDateVC, animated: true, completion: nil)
            return
            
        default:
            return
            
        }
    }
}

extension CreateTripTableViewController : ChooseDateViewControllerDelegate {
    
    func set(date: Date, sender: ChooseDateViewController) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateAsString = dateFormatter.string(from: date)
        
        if sender.isEndDate == false {
            tripStartDateLabel.text = dateAsString
            startDate = date
            
        } else {
            tripEndDateLabel.text = dateAsString
            endDate = date
        }
    }
}

extension CreateTripTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if self.tripDescriptionTextView.text == "Brief description (optional)" {
            self.tripDescriptionTextView.text = ""
            self.tripDescriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if self.tripDescriptionTextView.text.isEmpty {
            self.tripDescriptionTextView.text = "Brief description (optional)"
            self.tripDescriptionTextView.textColor = UIColor.lightGray
        }
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
