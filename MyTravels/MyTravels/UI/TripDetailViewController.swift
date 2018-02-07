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
    var trip: Trip?
    var array: Array<Any>?
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tripPhotoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set navigation bar title/properties
        guard let trip = trip else { return }
        self.title = trip.location
        
        // Set trip photo
        guard let tripPhoto = trip.photo?.photo,
            let image = UIImage(data: tripPhoto)
            else { return }
        tripPhotoImageView.image = image
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        PlaceController.shared.frc.delegate = self
        
        // Table view properties
        tableView.separatorStyle = .none
        
        setUpArrays()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpArrays()
    }
    
    // MARK: - Functions
    func setUpArrays() {
        
        guard let trip = trip,
            let places = trip.places,
            let placesArray = places.allObjects as? [Place] else { return }
        
        var array: [[Place]] = []
        var lodgingArray: [Place] = []
        var restaurantsArray: [Place] = []
        var activitiesArray: [Place] = []
        
        for place in placesArray {
            
            if place.type == "Lodging" {
                lodgingArray.append(place)
                
            } else if place.type == "Restaurant" {
                restaurantsArray.append(place)
                
            } else if place.type == "Activity" {
                activitiesArray.append(place)
            }
            
        }
        
        if lodgingArray.count > 0 {
            array.append(lodgingArray)
        }
        
        if restaurantsArray.count > 0 {
            array.append(restaurantsArray)
        }
        
        if activitiesArray.count > 0 {
            array.append(activitiesArray)
        }
        
        print("Array count: \(array.count)")
        print("Full array: \(array)")
        self.array = array
        
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
        
        guard let trip = trip else { return }
        
        if segue.identifier == "toCreateNewPlaceTableViewControllerSegue" {
            
            guard let destinationVC = segue.destination as? CreateNewPlaceTableViewController
                else { return }
            
            destinationVC.trip = trip
            
        }
        
        if segue.identifier == "toPlaceDetailTableViewController" {
           
            guard let destinationVC = segue.destination as? PlaceDetailTableViewController,
                let indexPath = tableView.indexPathForSelectedRow,
                let placeArray = array as? [[Place]]
                else { return }
            
            let place = placeArray[indexPath.section][indexPath.row]
            destinationVC.trip = trip
            destinationVC.place = place

        }
        
    }
    
}

extension TripDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
      
        guard let array = array else { return 0 }
        
        return array.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        guard let placeArray = array as? [[Place]],
        let firstItemInArray = placeArray[section].first,
            let firstItemInArrayType = firstItemInArray.type
        else { return UIView() }
        
        if firstItemInArrayType == "Lodging" {
            let text = "   Lodging"
            return sectionHeaderLabelWith(text: text)
            
        } else if firstItemInArrayType == "Restaurant" {
            let text = "   Restaurants"
            return sectionHeaderLabelWith(text: text)
            
        } else if firstItemInArrayType == "Activity" {
            let text = "   Activities"
            return sectionHeaderLabelWith(text: text)
        }
        return UIView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let placeArray = array as? [[Place]] else { return 0 }
        return placeArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        cell.selectionStyle = .none
        
        guard let placeArray = array as? [[Place]] else { return UITableViewCell() }
        let place = placeArray[indexPath.section][indexPath.row]
        
        cell.place = place
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
       
        if editingStyle == .delete {
            guard let placeArray = array as? [[Place]] else { return }
            let place = placeArray[indexPath.section][indexPath.row]
            PlaceController.shared.delete(place: place)
            setUpArrays()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
}
