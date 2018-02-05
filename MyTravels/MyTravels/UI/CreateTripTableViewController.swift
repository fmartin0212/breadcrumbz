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
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        imagePickerController.delegate = self
        
        // Photo properties
        photoImageView.layer.cornerRadius = 4
        
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let location = locationTextField.text,
            let startDate = startDate,
            let endDate = endDate,
            let photo = photo
            else { return }
        
        let newTrip = Trip(location: location, startDate: startDate, endDate: endDate, photo: photo)
        TripController.shared.create(trip: newTrip)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addPhotoGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Image picker controller delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.allowsEditing = true
        guard let photo = info[UIImagePickerControllerEditedImage] as? UIImage,
            let photoAsData = UIImagePNGRepresentation(photo)
            else { return }
        self.photo = photoAsData
        
        photoImageView.image = photo
        dismiss(animated: true, completion: nil)
        
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
            startDateTextField.text = dateAsString
            startDate = date
            
        } else {
            endDateTextField.text = dateAsString
            endDate = date
        }
        
    }
    
}

