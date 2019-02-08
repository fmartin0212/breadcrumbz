//
//  AddTripViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/7/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class AddTripViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var photoBackdropView: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var largeLineView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var startDateLineView: UIView!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var endDateLineView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatViews()
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
    }
}

extension AddTripViewController {
    
    func formatViews() {
        largeLineView.formatLine()
        startDateLineView.formatLine()
        endDateLineView.formatLine()
        
        // Text Fields
        nameTextField.format()
        locationTextField.format()
        
        // Photo backdrop
        photoBackdropView.layer.cornerRadius = photoBackdropView.frame.width / 2
        photoBackdropView.clipsToBounds = true
        
        addPhotoButton.format(withFontColor: UIColor.red, borderColor: UIColor.red, backgroundColor: UIColor.white)
        
        descriptionTextView.format()
        
        saveButton.format(withFontColor: .white, borderColor: .red, backgroundColor: .red)
    }
    
}
