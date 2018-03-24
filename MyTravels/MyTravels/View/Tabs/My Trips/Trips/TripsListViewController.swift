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
import MapKit

class TripsListViewController: UIViewController {
    
    // MARK: - Properties
//    var trips: [Trip]?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        navigationController?.navigationBar.prefersLargeTitles = true
        
        TripController.shared.fetchAllTrips()
//
//        var placesArray: [[Place]] = [[]]
//        for trip in TripController.shared.trips {
//            guard let places = trip.places?.allObjects as? [Place] else { return }
//            placesArray.append(places)
//        }
        
    }
    
    // FIXME: - Not needed? Not actually solving my problem.
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTripDetailViewSegue" {
            guard let destinationVC = segue.destination as? TripDetailViewController,
                let trips = TripController.shared.frc.fetchedObjects,
                let indexPath = tableView.indexPathForSelectedRow
                else { return }
            let trip = trips[indexPath.row]
            destinationVC.trip = trip
        }
    }
    
}

extension TripsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trips = TripController.shared.frc.fetchedObjects else { return 0 }
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        cell.selectionStyle = .none
        
        guard let trips = TripController.shared.frc.fetchedObjects else { return UITableViewCell() }
        let trip = trips[indexPath.row]
        cell.trip = trip
        
        return cell
        
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
