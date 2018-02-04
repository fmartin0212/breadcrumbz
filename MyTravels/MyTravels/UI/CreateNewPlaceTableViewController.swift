//
//  CreateNewPlaceTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/2/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateNewPlaceTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    var trip: Trip? {
        didSet {
            print("hello")
        }
    }
    let imagePickerController = UIImagePickerController()
    var photo: Data?
    var imageWasUploaded = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        imagePickerController.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext", size: 20)!]
        

    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
           dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let trip = self.trip,
            let name = nameTextField.text,
            let type = typeTextField.text,
            let address = addressTextField.text,
            let comments = commentTextView.text
            else { return }
        
        if imageWasUploaded == false {
            guard let photo = UIImage(named: "London") else { return }
            guard let photoAsData = UIImageJPEGRepresentation(photo, 11.0) else { return }
            PlaceController.shared.create(name: name, type: type, address: address, comments: comments, recommendation: true, photo: photoAsData, trip: trip)
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func typeTapGestureRecognized(_ sender: Any) {
        print("adsf")
        performSegue(withIdentifier: "toTypeSelectionViewController", sender: self)
        
    }
    
    // MARK: - Table view data source
/*
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
  
        if section == 1 {
      return sectionHeaderLabelWith(text: "Add a new place")
        }
        return UILabel()
    }
 
 */
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "toTypeSelectionViewController" {
            guard let destinationVC = segue.destination as? TypeSelectionViewController else { return }
            destinationVC.delegate = self
        }
        
    }

}

extension CreateNewPlaceTableViewController: TypeSelectionViewControllerDelegate {
    func set(type: String) {
        typeTextField.text = type
    }
}
