//
//  CreateTripViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateTripViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    let imagePicker = UIImagePickerController()
    var startDate: Date?
    var endDate: Date?
    var photoAsData: Data?
    
    // MARK: - IBOutlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        imagePicker.delegate = self
        
        // Set save button's edges to be round
        saveButton.layer.cornerRadius = 8
        saveButton.layer.borderColor = nil

    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        // Create bubbly effect upon tap
        UIView.animate(withDuration: 0.15, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.saveButton.transform = CGAffineTransform.identity
            })
        }
        
        guard let location = locationTextField.text,
            let startDate = startDate,
            let endDate = endDate,
            let photo = self.photoAsData
            else { return }
        
        TripController.shared.createTripWith(location: location, startDate: startDate, endDate: endDate)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Image picker delegate functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        addPhotoButton.setImage(image, for: .normal)
        addPhotoButton.imageView?.contentMode = .scaleToFill
        addPhotoLabel.isHidden = true
        
        guard let photoAsData = UIImagePNGRepresentation(image) else { return }
        self.photoAsData = photoAsData
        
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension CreateTripViewController: UIImagePickerController, UINavigationControllerDelegate {
//
//}

