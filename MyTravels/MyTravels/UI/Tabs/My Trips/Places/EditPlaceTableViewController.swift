//
//  EditPlaceTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/6/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class EditPlaceTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    var trip: Trip?
    var place: Place?
    var rating: Int16 = 0
    var photos: [Data] = []
    var imagePickerController = UIImagePickerController()
    
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
        
        // Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        imagePickerController.delegate = self
        
        imagePickerController.allowsEditing = true
        
        guard let place = place,
            let photosArray = place.photos?.allObjects as? [Photo]
            else { return }
        
        var photosAsData: [Data] = []
        for photo in photosArray {
            guard let photoAsData = photo.photo as Data? else { return }
            photosAsData.append(photoAsData)
        }
        
        self.photos = photosAsData
        rating = place.rating
        
        // Append Add photo image to photos array
        guard let addPhotoImage = UIImage(named: "AddTripPhoto256"),
            let addPhotoImageAsData = addPhotoImage.pngData() else { return }
        self.photos.insert(addPhotoImageAsData, at: 0)

        updateViews(place: place)
        
    }
    
    // MARK: - Functions
    func updateViews(place: Place) {
        
        placeNameTextField.text = place.name
        placeTypeTextField.text = place.type?.rawValue
        placeAddressTextField.text = place.address
        placeCommentsTextView.text = place.comments
        
        updateStarsImageViews(place: place)
        
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
       
        // Check to see if any required fields are empty, if so, present alertcontroller and jump out of function
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
            let place = self.place,
            let name = placeNameTextField.text,
            let typeAsString = placeTypeTextField.text,
            let type = Place.types(rawValue: typeAsString),
            let address = placeAddressTextField.text,
            let comments = placeCommentsTextView.text
            else { return }
        
        self.photos.remove(at: 0)

//        if imageWasUploaded == false {
//            guard let photo = UIImage(named: "London") else { return }
//            guard let photoAsData = UIImageJPEGRepresentation(photo, 11.0) else { return }
//            PlaceController.shared.create(name: name, type: type, address: address, comments: comments, rating: rating, trip: trip)
//
//            dismiss(animated: true, completion: nil)
//        }

        PlaceController.shared.update(place: place, name: name, type: type, address: address, comments: comments, rating: rating)
    
//        PhotoController.shared.update(photos: photos, for: place)
        dismiss(animated: true, completion: nil)
        
    }
    
    // Star rating actions
    
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
        
        if rating <= 2 || rating > 4 {
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
    
    // MARK: - Tap gesture recognizers
    @IBAction func typeTextFieldTapGestureRecognizerTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ToTypeSelectionViewController", sender: self)
    }
    
    func updateStarsImageViews(place: Place) {
        
        let starImageViewsArray = [starOne, starTwo, starThree, starFour, starFive]
        
        if place.rating == 0 {
            for starImageView in starImageViewsArray {
                starImageView?.image = UIImage(named: "star-clear-16")
            }
        } else if place.rating > 0 {
            var i = 0
            
            while i < Int(place.rating) {
                starImageViewsArray[i]?.image = UIImage(named: "star-black-16")
                i += 1
            }
            
            while i <= starImageViewsArray.count - 1 {
                starImageViewsArray[i]?.image = UIImage(named: "star-clear-16")
                i += 1
            }
        }
        
    }

    // MARK: - Table view data source
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ToTypeSelectionViewControllerSegue" {
            guard let destinationVC = segue.destination as? TypeSelectionViewController else { return }
            destinationVC.delegate = self
        }
        
        if segue.identifier == "ToSearchViewControllerSegue" {
            guard let destinationVC = segue.destination as? SearchViewController else { return }
            destinationVC.delegate = self
        }
        
    }
    
    // MARK: - Image picker controller delegate methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        guard let photo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage,
            let photoAsData = photo.pngData()
            else { return }
        
        self.photos.append(photoAsData)
        
        dismiss(animated: true, completion: collectionView.reloadData)
        
    }

}

extension EditPlaceTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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

extension EditPlaceTableViewController: TypeSelectionViewControllerDelegate {
    func set(type: String) {
        placeTypeTextField.text = type
    }
    
}

extension EditPlaceTableViewController: SearchViewControllerDelegate {
    func set(address: String) {
        placeAddressTextField.text = address
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
