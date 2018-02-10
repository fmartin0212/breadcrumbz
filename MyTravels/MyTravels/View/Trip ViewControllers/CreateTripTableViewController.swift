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
    var isEndDate: Bool = false
    var photo: Data?
    let imagePickerController = UIImagePickerController()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tripLocationTextField: UITextField!
    @IBOutlet weak var tripStartDateTextField: UITextField!
    @IBOutlet weak var tripEndDateTextField: UITextField!
    @IBOutlet weak var tripPhotoImageView: UIImageView!  {
        didSet {
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Delegates
        imagePickerController.delegate = self
        
        // Photo properties
        tripPhotoImageView.layer.cornerRadius = 4
        
        imagePickerController.allowsEditing = true
        
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        // Check to see if any required fields are empty, if so, present alertcontroller and jump out of function
        guard let tripLocationTF = tripLocationTextField,
            let tripStartDateTF = tripStartDateTextField,
            let tripEndDateTF = tripEndDateTextField
            else { return }
        
        let textFields = [tripLocationTF, tripStartDateTF, tripEndDateTF]
        
        if tripLocationTextField.text?.isEmpty == true ||
            tripStartDateTextField.text == "Choose a start date" ||
            tripStartDateTextField.text == "Choose an end date"  {
            missingFieldAlert(textFields: textFields)
            return
            
        }
        
        guard let location = tripLocationTextField.text,
            let startDate = startDate,
            let endDate = endDate
            else { return }
        
        TripController.shared.createTripWith(location: location, startDate: startDate, endDate: endDate)
        
        // Get newly created trip and add the photo to it
        guard let trip = TripController.shared.trip,
            let photo = photo else { dismiss(animated: true, completion: nil) ; return }
        PhotoController.shared.add(photo: photo, trip: trip)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addPhotoGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Image picker controller delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        picker.sourceType = .photoLibrary

        guard let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) else { return }
        picker.mediaTypes = availableMediaTypes
        guard let photo = info[UIImagePickerControllerEditedImage] as? UIImage
            else { print("photo nil") ; return }
        guard let photoAsData = UIImagePNGRepresentation(photo) else { return }
        self.photo = photoAsData
        
        self.tripPhotoImageView.image = photo
        self.tripPhotoImageView.contentMode = .scaleAspectFit
        
        dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toChooseStartDateViewControllerSegue" {
            guard let destinationVC = segue.destination as? ChooseDateViewController
                else { return }
            
            isEndDate = false
            destinationVC.isEndDate = isEndDate
            destinationVC.delegate = self
        }
        
        if segue.identifier == "toChooseEndDateViewControllerSegue" {
            guard let destinationVC = segue.destination as? ChooseDateViewController
                else { return }
            
            isEndDate = true
            destinationVC.isEndDate = isEndDate
            destinationVC.delegate = self
        }
    }
    
}

extension CreateTripTableViewController: ChooseDateViewControllerDelegate {
    
    func set(date: Date) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateAsString = dateFormatter.string(from: date)
        
        if isEndDate == false {
            tripStartDateTextField.text = dateAsString
            startDate = date
            
        } else {
            tripEndDateTextField.text = dateAsString
            endDate = date
        }
        
    }
    
}

