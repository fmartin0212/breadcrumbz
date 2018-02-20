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

class TripsListViewController: UIViewController {

    // MARK: - Properties
    var trips: [Trip]?
    var tripsSharedWithUser = [LocalTrip]()
    var firstSharedTripsLoad = true
    var myTripsSelected: Bool {
        if segementedController.selectedSegmentIndex == 0 {
            return true
        }
        else if segementedController.selectedSegmentIndex == 1 {
            return false
        }
        return true
    }
    
    // MARK - IBOutlets
    @IBOutlet var addTripBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var segementedController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        visualEffectView.alpha = 0
        if UserController.shared.loggedInUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createAccountViewController = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController")

            UIView.animate(withDuration: 0.75, animations: {
                self.present(createAccountViewController, animated: true, completion: nil)
            })
        }
        
        // Set navigation bar properties
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Avenir Next", size: 20)!]
     
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        TripController.shared.frc.delegate = self
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
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
        
    }
    
    // MARK: - IBActions
    @IBAction func segementedControllerTapped(_ sender: UISegmentedControl) {
        if myTripsSelected == true {
            self.navigationItem.rightBarButtonItem = addTripBarButtonItem
            tableView.reloadData()
        }
        if myTripsSelected == false {
            self.visualEffectView.alpha = 1
            self.navigationItem.rightBarButtonItem = nil
            
            if firstSharedTripsLoad == true {
                SharedTripsController.shared.fetchTripsSharedWithUser(completion: { (tripsSharedWithUser) in
                    self.tripsSharedWithUser = tripsSharedWithUser
                    SharedTripsController.shared.fetchPlacesForTrips(sharedTrips: tripsSharedWithUser, completion: { (success) -> (Void) in
                        print("shared trips count: \(SharedTripsController.shared.sharedTrips.count)")
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            UIView.animate(withDuration: 0.2, animations: {
                                self.visualEffectView.alpha = 0
                                
                            })
                        }
                    })
                })
            }
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
        }
            
        else {
            
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
            return tripsSharedWithUser.count
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
