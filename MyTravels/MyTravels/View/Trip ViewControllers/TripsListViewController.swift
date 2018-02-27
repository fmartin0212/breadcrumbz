//
//  TripsListViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import Contacts

class TripsListViewController: UIViewController {
    
    // MARK: - Properties
    var trips: [Trip]?
    var tripsSharedWithUser = [SharedTrip]()
    var myTripsSelected: Bool {
        if segementedController.selectedSegmentIndex == 0 {
            return true
        }
        else if segementedController.selectedSegmentIndex == 1 {
            return false
        }
        return true
    }
    
    // MARK: - IBOutlets
    @IBOutlet var addTripBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var segementedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    // FIXME: - Is this needed?
    @IBOutlet var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // FIXME: - Is this needed?
        visualEffectView.alpha = 0
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        TripController.shared.frc.delegate = self
        
        // Check to see if there is a current user logged in, if not, present sign-up view
        if UserController.shared.loggedInUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createAccountViewController = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController")
            
            UIView.animate(withDuration: 0.75, animations: {
                self.present(createAccountViewController, animated: true, completion: nil)
            })
        }
        
        // Set navigation bar properties
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 20)!]
        
        // Fetch all of the trips/places from Core Data and set them to local variables
        do {
            try TripController.shared.frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
        }
        
        guard let trips = TripController.shared.frc.fetchedObjects else { return }
        self.trips = trips
        TripController.shared.trips = trips
        
        var placesArray: [[Place]] = [[]]
        for trip in trips {
            guard let places = trip.places?.allObjects as? [Place] else { return }
            placesArray.append(places)
        }
        
        // FIXME: - Remove once in correct place
        let contactStore = CNContactStore()
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor])
        try? contactStore.enumerateContacts(with: fetchRequest) { (contact, _) in
            DispatchQueue.main.async {
            let firstName = contact.givenName
            let lastName = contact.familyName
            guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else { return }
//            print("CONTACT INFORMATION: \(firstName) \(lastName),\(phoneNumber)")
                var phoneNumberArray = [String]()
                for character in phoneNumber.unicodeScalars {
                    let characterAsString = String(character)
                    if character.value >= 48 && character.value < 58 {
                        phoneNumberArray.append(characterAsString)
                        
                    }
                
                }
                if Int(phoneNumberArray.first!) == 1 {
                    phoneNumberArray.remove(at: 0)
                }
                print("\(firstName), \(lastName), \(phoneNumberArray)")
            }
        }
        
        
    }
    
    // MARK: - IBActions
    @IBAction func segementedControllerTapped(_ sender: UISegmentedControl) {
        
        if myTripsSelected == true {
            self.navigationItem.rightBarButtonItem = addTripBarButtonItem
            tableView.reloadData()
        }
        
        if myTripsSelected == false {
            self.navigationItem.rightBarButtonItem = nil
            tableView.reloadData()
        }
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if myTripsSelected == true {
            
            if segue.identifier == "toTripDetailViewSegue" {
                guard let destinationVC = segue.destination as? TripDetailViewController,
                    let trips = TripController.shared.frc.fetchedObjects,
                    let indexPath = tableView.indexPathForSelectedRow
                    else { return }
                let trip = trips[indexPath.row]
                destinationVC.trip = trip
            }
        } else {
            
            if segue.identifier == "toTripDetailViewSegue" {
                guard let destinationVC = segue.destination as? TripDetailViewController,
                    let indexPath = tableView.indexPathForSelectedRow
                    else { return }
                
                let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
                destinationVC.sharedTrip = sharedTrip
            }
        }
    }
    
}

extension TripsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if myTripsSelected == true {
            guard let trips = TripController.shared.frc.fetchedObjects else { return 0 }
            return trips.count
        }
        if myTripsSelected == false {
            print("adsf")
            return SharedTripsController.shared.sharedTrips.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        cell.selectionStyle = .none
        
        if myTripsSelected == true {
            guard let trips = TripController.shared.frc.fetchedObjects else { return UITableViewCell() }
            let trip = trips[indexPath.row]
            let photo = trip.photo
            cell.trip = trip
        } else if myTripsSelected == false {
            let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
            cell.localTrip = sharedTrip
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let trips = TripController.shared.frc.fetchedObjects else { return }
            let trip = trips[indexPath.row]
            TripController.shared.delete(trip: trip)
        }
    }
    
}

extension TripsListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}
