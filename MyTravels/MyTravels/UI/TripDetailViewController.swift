//
//  TripDetailViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/31/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData

class TripDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    var trip: Trip? {
        didSet {
            print("Trip name: \(trip?.location)")
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        PlaceController.shared.frc.delegate = self
        
        tableView.reloadData()
    
    }
    
    // MARK: - Fetched  Resuts Controller Delegate methods
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
    
    
     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "toCreateNewPlaceSegue" {
            guard let destinationVC = segue.destination as? CreateNewPlaceViewController,
                let trip = self.trip
                else { return }

            destinationVC.trip = trip
            
        }
     }

}

extension TripDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let trip = trip,
            let places = trip.places else { return 0 }
        print(places.count)
        return places.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! TripPlaceTableViewCell
        
        guard let trip = trip,
            let places = trip.places else { return UITableViewCell() }
        
        let placesArray = places.allObjects
        print(placesArray.count)
        guard let place = placesArray[indexPath.row] as? Place else { return UITableViewCell() }
        
        cell.place = place
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}
