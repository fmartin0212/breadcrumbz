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
    var rating: Int16 = 0
    var mockPhotoData: [Data]?
    var photos: [Data] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
    @IBOutlet weak var placeNameTextField: UITextField!
    @IBOutlet weak var placeTypeTextField: UITextField!
    @IBOutlet weak var placeAddressTextField: UITextField!
    @IBOutlet weak var placeCommentsTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let addPhotoImage = UIImage(named: "AddTripPhoto256"),
            let addPhotoImageAsData = UIImagePNGRepresentation(addPhotoImage) else { return }
        self.photos.insert(addPhotoImageAsData, at: 0)

        // Delegates
        imagePickerController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext", size: 20)!]
        
        // Set textview placeholder text
        placeCommentsTextView.text = "Comments"
        placeCommentsTextView.textColor = #colorLiteral(red: 0.8037719131, green: 0.8036019206, blue: 0.8242246509, alpha: 1)

    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
           dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let placeNameTF = placeNameTextField,
            let placeTypeTF = placeTypeTextField,
            let placeAddressTF = placeAddressTextField
            else { return }
        
        let textFields = [placeNameTF, placeTypeTF, placeAddressTF]
        
        
        if placeNameTextField.text?.isEmpty == true ||
            placeTypeTextField.text == "Choose a type" ||
            placeAddressTextField.text?.isEmpty == true  {
            missingFieldAlert(textFields: textFields)
            return
            
        }
        
        guard let trip = self.trip,
            let name = placeNameTextField.text,
            let type = placeTypeTextField.text,
            let address = placeAddressTextField.text,
            let comments = placeCommentsTextView.text
            else { return }
        
        self.photos.remove(at: 0)
        
        if imageWasUploaded == false {
            guard let photo = UIImage(named: "London") else { return }
            guard let photoAsData = UIImageJPEGRepresentation(photo, 11.0) else { return }
            PlaceController.shared.create(name: name, type: type, address: address, comments: comments, rating: rating, trip: trip)
        
            dismiss(animated: true, completion: nil)
        }
        
        PlaceController.shared.create(name: name, type: type, address: address, comments: comments, rating: rating, trip: trip)
        guard let place = PlaceController.shared.place else { return }
        PhotoController.shared.add(photos: self.photos, place: place)
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Tap gesture recognizers
    // Star rating

    @IBAction func starOneGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        print("star one tapped")
        if rating == 1 {
            starOne.image = UIImage(named: "star-clear-24")
            starTwo.image = UIImage(named: "star-clear-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 0
            return
        
        }
        
        if rating == 0 || rating > 1 {
            starOne.image = UIImage(named: "star-black-24")
            starTwo.image = UIImage(named: "star-clear-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 1
        }
        
    }
    
    @IBAction func starTwoGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        print("star two tapped")
        
        if rating == 2 {
            starOne.image = UIImage(named: "star-clear-24")
            starTwo.image = UIImage(named: "star-clear-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 0
            return
            
        }
        
        if rating <= 1 || rating > 2 {
            starOne.image = UIImage(named: "star-black-24")
            starTwo.image = UIImage(named: "star-black-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 2
        }
        
    }
    
    @IBAction func starThreeGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        print("star three tapped")
        
        if rating == 3 {
            starOne.image = UIImage(named: "star-clear-24")
            starTwo.image = UIImage(named: "star-clear-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 0
            return
            
        }
        
        if rating <= 2 || rating >= 4 {
            starOne.image = UIImage(named: "star-black-24")
            starTwo.image = UIImage(named: "star-black-24")
            starThree.image = UIImage(named: "star-black-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 3
        }
        
    }
    
    @IBAction func starFourGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        print("star four tapped")
        
        if rating == 4 {
            starOne.image = UIImage(named: "star-clear-24")
            starTwo.image = UIImage(named: "star-clear-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 0
            return
            
        }
        
        if rating <= 3 || rating == 5 {
            starOne.image = UIImage(named: "star-black-24")
            starTwo.image = UIImage(named: "star-black-24")
            starThree.image = UIImage(named: "star-black-24")
            starFour.image = UIImage(named: "star-black-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 4
        }
    
    }
    
    @IBAction func starFiveGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        print("star five tapped")
        
        if rating == 5 {
            starOne.image = UIImage(named: "star-clear-24")
            starTwo.image = UIImage(named: "star-clear-24")
            starThree.image = UIImage(named: "star-clear-24")
            starFour.image = UIImage(named: "star-clear-24")
            starFive.image = UIImage(named: "star-clear-24")
            rating = 0
            return
            
        }
        
        if rating < 5 {
            starOne.image = UIImage(named: "star-black-24")
            starTwo.image = UIImage(named: "star-black-24")
            starThree.image = UIImage(named: "star-black-24")
            starFour.image = UIImage(named: "star-black-24")
            starFive.image = UIImage(named: "star-black-24")
            rating = 5
        }
        
    }
    
    @IBAction func typeTapGestureRecognizerTapped(_ sender: Any) {
        performSegue(withIdentifier: "toTypeSelectionViewController", sender: self)
        
    }
    
    // MARK : - Functions
    func calculateStars() {
        // FIX ME: THIS.
    }
    
    // MARK: - Image picker controller delegate methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
        imagePickerController.allowsEditing = true
        guard let photo = info[UIImagePickerControllerEditedImage] as? UIImage,
            let photoAsData = UIImagePNGRepresentation(photo)
            else { return }
        
        self.photos.append(photoAsData)
       
        if self.photos.count > 1 {
            imageWasUploaded = true
        }
        
        dismiss(animated: true, completion: collectionView.reloadData)
        
    }
    
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
        placeTypeTextField.text = type
    }
}

extension CreateNewPlaceTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
            cell.photo = photos[indexPath.row]
            return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        if indexPath.row == 0 {
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
}

extension CreateNewPlaceTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if self.placeCommentsTextView.textColor == UIColor.lightGray {
            self.placeCommentsTextView.text = nil
            self.placeCommentsTextView.textColor = UIColor.black
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
       
        if self.placeCommentsTextView.text.isEmpty {
            self.placeCommentsTextView.text = "Comments"
            self.placeCommentsTextView.textColor = UIColor.lightGray
        }
        
    }
    
}
