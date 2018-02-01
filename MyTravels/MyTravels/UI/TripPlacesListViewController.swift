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

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        PlaceController.shared.frc.delegate = self
        
        // Perform fetch request
        do {
            try PlaceController.shared.frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
            
            
        }
    }
    
    // MARK: - Fetched  resuts controller observer
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension TripDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let places = PlaceController.shared.frc.fetchedObjects else { return 0 }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! TripPlaceTableViewCell
        guard let places = PlaceController.shared.frc.fetchedObjects else { return UITableViewCell() }
        let place = places[indexPath.row]
        cell.place = place
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}
