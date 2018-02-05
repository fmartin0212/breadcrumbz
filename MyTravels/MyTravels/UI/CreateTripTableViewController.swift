//
//  CreateTripTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/4/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateTripTableViewController: UITableViewController {
    
    // MARK: - Properties
    var startDate: Date?
    var endDate: Date?
    var isEndDate: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let location = locationTextField.text,
            let startDate = startDate,
            let endDate = endDate
            else { return }
        
        // FIX ME: - update to be actual trip photo once collection view/picker added
        guard let photo = UIImage(named: "London"),
            let photoAsData = UIImagePNGRepresentation(photo) else { return }
        
        let newTrip = Trip(location: location, startDate: startDate, endDate: endDate, photo: photoAsData)
        TripController.shared.create(trip: newTrip)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toChooseStartDateViewControllerSegue" {
            guard let destinationVC = segue.destination as? ChooseDateViewController
                else { return }
            
            isEndDate = false
            destinationVC.isEndDate = isEndDate
            destinationVC.delegate = self
        }
        
        if segue.identifier == "toChooseEndDateViewControllerSegue" {
            guard let destinationVC = segue.destination as? ChooseDateViewController
                else { return }
            
            isEndDate = true
            destinationVC.isEndDate = isEndDate
            destinationVC.delegate = self
        }
    }
    
}

extension CreateTripTableViewController: ChooseDateViewControllerDelegate {
    
    func set(date: Date) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateAsString = dateFormatter.string(from: date)
        
        if isEndDate == false {
            startDateTextField.text = dateAsString
            startDate = date
            
        } else {
            endDateTextField.text = dateAsString
            endDate = date
        }
        
    }
    
}

