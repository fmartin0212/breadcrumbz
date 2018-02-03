//
//  CreateNewPlaceViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/31/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateNewPlaceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    let imagePickerController = UIImagePickerController()
    var photo: Data?
    var imageWasUploaded = false
    var trip: Trip? {
        didSet {
            print("hello")
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        imagePickerController.delegate = self
    }

    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
      
        guard let name = nameTextField.text,
            let type = typeTextField.text,
            let address = addressTextField.text,
            let comments = commentsTextView.text,
            let trip = self.trip
            else { return }
        
        if imageWasUploaded == false {
            guard let photo = UIImage(named: "world") else { return }
            guard let photoAsData = UIImageJPEGRepresentation(photo, 11.0) else { return }
            PlaceController.shared.create(name: name, type: type, address: address, comments: comments, recommendation: true, photo: photoAsData, trip: trip)
            
            dismiss(animated: true, completion: nil)
        }
//        let _ = Place(name: name, type: type, address: address, comments: comments, recommendation: true, photo: photo)
//        PlaceController.shared.create()
//
//        dismiss(animated: true, completion: nil)
        
        
    }
    
    // Image picker delegate functions
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePickerController.allowsEditing = true
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        addPhotoButton.setImage(image, for: .normal)
        addPhotoButton.contentMode = .scaleAspectFit
        
        guard let photoAsData = UIImagePNGRepresentation(image) else { return }
        self.photo = photoAsData
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTypeSelectionViewController" {
            guard let destinationVC = segue.destination as? TypeSelectionViewController else { return }
            destinationVC.delegate = self
        }
    }

}

extension CreateNewPlaceViewController: TypeSelectionViewControllerDelegate {
    func set(type: String) {
        typeTextField.text = type
    }
}
