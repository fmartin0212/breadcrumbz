//
//  AddCrumbViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 2/25/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class AddCrumbViewController: UIViewController, ScrollableViewController {
    
    // MARK: - Properties
    
    // Scrollable View Controller
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    var selectedTextField: UITextField?
    var selectedTextView: UITextView?
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    
    var trip: TripObject?
    var photoData: Data?
    let imagePickerController = UIImagePickerController()
    var type: String?
    var fromSearchVC = false
    var photos: [Int : Data] = [:]
    var selectedCollectionViewCell: ImageCollectionViewCell?
    
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
        imagePickerController.allowsEditing = true
        nameTextField.delegate = self
        addressTextField.delegate = self
        commentsTextView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        
        let imageCollectionViewCell = UINib(nibName: "ImageCollectionViewCell", bundle: nil)
        imageCollectionView.register(imageCollectionViewCell, forCellWithReuseIdentifier: "imageCell")
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            self.adjustScrollView(keyboardFrame: keyboardFrame!, bottomConstraint: self.saveButtonBottomConstraint)
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardDidHide, object: nil, queue: .main) { (notification) in
            self.saveButtonBottomConstraint.constant = 100
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text,
            !name.isEmpty,
            let address = addressTextField.text,
            !address.isEmpty,
            // FIXME : -
            let placeType = Place.types(rawValue: "restaurant"),
            let trip = trip
        else { return }
        
        let place = PlaceController.shared.createNewPlaceWith(name: name, type: placeType, address: address, comments: commentsTextView.text, rating: 0, trip: trip as! Trip)
        PhotoController.shared.add(photos: self.photos, place: place)
        self.dismiss(animated: true, completion: nil)
        
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
        
        // Buttons
        saveButton.layer.cornerRadius = 12
        
        // Text View
        commentsTextView.format()
    }
}


extension AddCrumbViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let photo = info[UIImagePickerControllerEditedImage] as? UIImage,
            let photoData = UIImageJPEGRepresentation(photo, 0.1),
            let cell = selectedCollectionViewCell,
            let indexPath = imageCollectionView.indexPath(for: cell)
            else { return }
        
        if self.photos[indexPath.row] != nil {
            self.photos.removeValue(forKey: indexPath.row)
        }
        self.photos[indexPath.row] = photoData
        cell.addPhotoButton.setImage(photo, for: .normal)
        cell.addPhotoButton.imageView?.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
}


extension AddCrumbViewController: UITextFieldDelegate {
    
    // Part of ScrollableViewController implementation
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if fromSearchVC {
            fromSearchVC = false
            return false
        }
        if textField.tag == 3 {
            let searchVC = UIStoryboard.main.instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
            searchVC.delegate = self
            present(searchVC, animated: true, completion: nil)
            return false
        }
        return true
    }
    
}

extension AddCrumbViewController: SearchViewControllerDelegate {
    
    func set(address: String) {
        addressTextField.text = address
        fromSearchVC = true
    }
}

extension AddCrumbViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.selectedTextView = textView
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.returnKeyType = .done
    }
    
}

extension AddCrumbViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        if indexPath.row > 0 {
            cell.addPhotoButton.setImage(UIImage(named: "uploadcloudonly"), for: .normal)
        }
        
        cell.delegate = self
        cell.clipsToBounds = true
        cell.layer.cornerRadius = 8
        
        return cell
    }
}

extension AddCrumbViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.width, height: 200)
        } else {
            return CGSize(width: (collectionView.frame.width / 3) - 8, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension AddCrumbViewController: ImageCollectionViewCellDelegate {
    
    func addPhotoButtonTapped(cell: ImageCollectionViewCell) {
        selectedCollectionViewCell = cell
        present(imagePickerController, animated: true, completion: nil)
    }
}
