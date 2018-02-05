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
    
    // MARK: - IBOutlets
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        imagePickerController.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
            PlaceController.shared.create(name: name, type: type, address: address, comments: comments, rating: rating, photo: photoAsData, trip: trip)
            
            dismiss(animated: true, completion: nil)
        }
        
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
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func typeTapGestureRecognized(_ sender: Any) {
        performSegue(withIdentifier: "toTypeSelectionViewController", sender: self)
        
    }
    
    // MARK : - Functions
    func calculateStars() {
        
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

extension CreateNewPlaceTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let image = UIImage(named: "AddTripPhoto256"),
        let photo = UIImagePNGRepresentation(image)
        else { return 0 }
        guard let image1 = UIImage(named: "London"),
            let image2 = UIImage(named: "world"),
            let image1AsData = UIImagePNGRepresentation(image1),
            let image2AsData = UIImagePNGRepresentation(image2)
            else { return 0 }
        var mockPhotoData = [image1AsData, image2AsData]
        self.mockPhotoData = mockPhotoData
        guard var mockPhotoDataUnwrapped = self.mockPhotoData else { return 0 }
        mockPhotoDataUnwrapped.insert(photo, at: 0)
        self.mockPhotoData = mockPhotoDataUnwrapped
        
        return mockPhotoDataUnwrapped.count

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        guard let mockPhotoData = self.mockPhotoData else { return UICollectionViewCell() }
        if indexPath.row == 0 {
            guard let photo = UIImage(named: "AddTripPhoto256"),
                let photoAsData = UIImagePNGRepresentation(photo)
                else { return UICollectionViewCell() }
            cell.photo = photoAsData
            return cell
        } else if indexPath.row > 0 {
            let photo = mockPhotoData[indexPath.row]
            cell.photo = photo

            return cell
        }
        return UICollectionViewCell()
    }
    
}
