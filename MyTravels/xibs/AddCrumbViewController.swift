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
    var type: Place.types = .activity
    var fromSearchVC = false
    var photos: [Int : Data] = [:]
    var selectedCollectionViewCell: ImageCollectionViewCell?

    let checkmarkView: UIView = {
        let checkmarkView = UIView()
        checkmarkView.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        checkmarkView.clipsToBounds = true
        checkmarkView.layer.cornerRadius = 8
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(named: "checkmark")
        checkmarkView.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: checkmarkImageView, attribute: .centerX, relatedBy: .equal, toItem: checkmarkView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: checkmarkImageView, attribute: .centerY, relatedBy: .equal, toItem: checkmarkView, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        return checkmarkView
    }()
    
    @IBOutlet var typeButtons: [UIButton]!
    
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
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            guard let userInfo = notification.userInfo else { return }
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            self.adjustScrollView(keyboardFrame: keyboardFrame!)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (notification) in
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

    @IBAction func typeButton(_ sender: UIButton) {
        setType(for: sender)
    }
    
}

extension AddCrumbViewController {
    
    func formatViews() {
        
        // Buttons
        saveButton.layer.cornerRadius = 12
        typeButtons.forEach { $0.layer.cornerRadius = 6 }
        setType(for: typeButtons.first!)
        
        // Text View
        commentsTextView.format()
    }
    
    func setType(for button: UIButton) {
        guard let typeString = button.restorationIdentifier,
            let type = Place.types(rawValue: typeString)
            else { return }
        
        checkmarkView.removeFromSuperview()
        
        typeButtons.forEach { $0.layer.borderWidth = 0; $0.setTitleColor(#colorLiteral(red: 0.6077903509, green: 0.6078781486, blue: 0.607762754, alpha: 1), for: .normal) }
        
        self.type = type
        
        button.layer.borderColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        button.layer.borderWidth = 1.5
        button.setTitleColor(#colorLiteral(red: 0.3621281683, green: 0.3621373773, blue: 0.3621324301, alpha: 1), for: .normal)
        
        contentView.addSubview(checkmarkView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: checkmarkView, attribute: .centerX, relatedBy: .equal, toItem: button, attribute: .trailing, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: checkmarkView, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: checkmarkView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 16),
            NSLayoutConstraint(item: checkmarkView, attribute: .width, relatedBy: .equal, toItem: checkmarkView, attribute: .height, multiplier: 1.0, constant: 0)
            ])
    }
}


extension AddCrumbViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        guard let photo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage,
            let photoData = photo.jpegData(compressionQuality: 0.1),
            let cell = selectedCollectionViewCell,
            let indexPath = imageCollectionView.indexPath(for: cell)
            else { return }
        
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
            let width = collectionView.frame.width / 3
            let minSpacInterimSpacing: CGFloat = 8
            return CGSize(width: width - minSpacInterimSpacing, height: width)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
