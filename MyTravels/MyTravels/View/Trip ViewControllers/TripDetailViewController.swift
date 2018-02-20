//
//  TripDetailViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/31/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class TripDetailViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    var sharedTripsView: Bool?
    var trip: Trip? {
        didSet {
         sharedTripsView = false
        }
    }
    var sharedTrip: LocalTrip? {
        didSet {
            sharedTripsView = true
        }
    }
    var array: Array<Any>?
  
    var sharedPlacesArray: [[LocalPlace]]?

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tripPhotoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set navigation bar title/properties
        if let trip = trip {
            
        self.title = trip.location
        
        // Set trip photo
        var tripPhoto = UIImage()
        guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
        tripPhoto = tripPhotoPlaceholderImage
        if let photo = trip.photo?.photo as Data? {
            guard let image = UIImage(data: photo) else { return }
            tripPhoto = image
        }
    
        tripPhotoImageView.image = tripPhoto
        
        }
        
        if let sharedTrip = sharedTrip {
    
            self.title = sharedTrip.location
        // Set shared trip photo
            var tripPhoto = UIImage()
            guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
            tripPhoto = tripPhotoPlaceholderImage
            if let photo = sharedTrip.photoData {
                guard let image = UIImage(data: photo) else { return }
                tripPhoto = image
            }
            
            tripPhotoImageView.image = tripPhoto
            
        }
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Table view properties
        tableView.separatorStyle = .none
        
        setUpArrays()
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpArrays()
    }
    
    // MARK: - IBActions
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareTripAction = UIAlertAction(title: "Share trip", style: .default) { (action) in
            guard let trip = self.trip else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let usernameSearchViewController = storyboard.instantiateViewController(withIdentifier: "UsernameSearchViewController") as? UsernameSearchViewController else { return }
            usernameSearchViewController.trip = trip
            self.present(usernameSearchViewController, animated: true, completion: {
                
            })
        
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(shareTripAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true) {
            
        }
    }
    
    
    // MARK: - Functions
    func setUpArrays() {
        
        if let trip = trip {
            guard let places = trip.places,
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
        
        }
        
        if let sharedTrip = sharedTrip  {
            
            let places = sharedTrip.places
            
            var array: [[LocalPlace]] = []
            var lodgingArray: [LocalPlace] = []
            var restaurantsArray: [LocalPlace] = []
            var activitiesArray: [LocalPlace] = []
            
            for place in places {
                
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
            self.sharedPlacesArray = array
            
        }
        
        tableView.reloadData()
        
    }
    
    func updateViewsForTrip() {
        
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
        if sharedTripsView == true {
            guard let sharedPlacesArray = sharedPlacesArray else { return 0 }
            print("dasf")
            return sharedPlacesArray.count
        }
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
            let text = "  Lodging"
            return sectionHeaderLabelWith(text: text)
            
        } else if firstItemInArrayType == "Restaurant" {
            let text = "  Restaurants"
            return sectionHeaderLabelWith(text: text)
            
        } else if firstItemInArrayType == "Activity" {
            let text = "  Activities"
            return sectionHeaderLabelWith(text: text)
        }
        return UIView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sharedTripsView == false {
        guard let placeArray = array as? [[Place]] else { return 0 }
        return placeArray[section].count
        }
        guard let sharedPlaces = sharedPlacesArray else { return 0 }
        return sharedPlaces[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if sharedTripsView == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
            cell.selectionStyle = .none
            
            guard let sharedPlacesArray = sharedPlacesArray else { return UITableViewCell() }
            let sharedPlace = sharedPlacesArray[indexPath.section][indexPath.row]
            
            cell.sharedPlace = sharedPlace
            
            return cell
        }
        
        
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
