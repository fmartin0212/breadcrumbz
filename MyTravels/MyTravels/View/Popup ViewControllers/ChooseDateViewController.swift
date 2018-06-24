//
//  ChooseDateViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/4/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

protocol ChooseDateViewControllerDelegate: class {
    func set(date: Date)
}

class ChooseDateViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: ChooseDateViewControllerDelegate?
    var isEndDate: Bool?
    
    // MARK: - IBOutlets
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var chooseDateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPropertiesFor(overlayView: overlayView)
        setLabelText()
        
        saveButton.clipsToBounds = true
        saveButton.layer.cornerRadius = 8
    }

    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        delegate?.set(date: datePicker.date)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Functions
    func setLabelText() {
        if isEndDate == true {
            chooseDateLabel.text = "Choose an end date"
        }
    }

}
