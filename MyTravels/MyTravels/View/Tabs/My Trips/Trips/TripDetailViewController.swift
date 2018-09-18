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
    var trip: Trip?
    var array: Array<Any>?

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tripPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set navigation bar title/properties
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        if let trip = trip {
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
        
        tableView.setContentOffset(CGPoint(x: (navigationController?.navigationBar.frame.origin.x)!, y: (navigationController?.navigationBar.frame.origin.y)!), animated: true)
        
        // Delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Table view properties
        tableView.separatorStyle = .singleLine
        
        setUpArrays()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpArrays()
    }
    
    // MARK: - IBActions
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareTripAction = UIAlertAction(title: "Share trip", style: .default) { (action) in
            if UserController.shared.loggedInUser == nil {
                self.presentCreateAccountAlert()
                return
            }
            
            CloudKitManager.shared.performFullSync(completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.presentShareAlertController()
                    }
                }
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
        
        tableView.reloadData()
        
    }
    
    func presentShareAlertController() {
        
        let alertController = UIAlertController(title: "Share trip", message: "Enter a username below to share your trip", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            guard let trip = self.trip,
                let username = alertController.textFields?.first!.text else { return }
            
            let predicate = NSPredicate(format: "username == %@", username)
            let query = CKQuery(recordType: "User", predicate: predicate)
            CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                guard let userRecord = records?.first,
                    let user = User(ckRecord: userRecord),
                    let tripReference = trip.reference
                    else { return }
                
                // If anything is in the user's pending refs list, append the new tripReference; otherwise, set the refs list to a new array with the trip reference.
                //        if let userPendingSharedTripsRefs = user.pendingSharedTripsRefs {
                if user.pendingSharedTripsRefs.contains(tripReference) {
                    
                    let alert = UIAlertController(title: "Oops!", message: "You have already shared this trip with this user. Please choose someone else.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                } else {
                    user.pendingSharedTripsRefs.append(tripReference)
                }
                
                guard let record = CKRecord(user: user) else { return }
                CloudKitManager.shared.updateOperation(records: [record]) { (_) in
                    DispatchQueue.main.async {
                        print("break")
                    }
                }
            })
        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentCreateAccountAlert() {
        let alertController = UIAlertController(title: nil, message: "Please create an account in order to share trips", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let createAccountAction = UIAlertAction(title: "Create account", style: .default) { (_) in
            let sb = UIStoryboard(name: "Onboarding", bundle: nil)
            let createAccountVC = sb.instantiateViewController(withIdentifier: "SignUp")
//            createAccountVC.sk
            self.present(createAccountVC, animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(createAccountAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toCreateNewPlaceTableViewControllerSegue" {
            guard let trip = trip,
                let destinationVC = segue.destination as? CreateNewPlaceTableViewController
                else { return }
            
            destinationVC.trip = trip
        }
        
        if segue.identifier == "toPlaceDetailTableViewController" {
            
            guard let trip = trip,
                let destinationVC = segue.destination as? PlaceDetailTableViewController,
                let indexPath = tableView.indexPathForSelectedRow,
                let placeArray = array as? [[Place]]
                else { return }
            
            let place = placeArray[indexPath.section - 2][indexPath.row]
            destinationVC.trip = trip
            destinationVC.place = place
            
        }
    }
}
extension TripDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let array = array else { return 0 }
        return array.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let placeArray = array as? [[Place]] else { return 0 }

        if section == 0 {
            return 1
        }
        
        if section == 1 {
            return 1
        }
        
        if section > 1 {
            return placeArray[section - 2].count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0  && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripDetailCell") as! TripDetailTableViewCell
            if let trip = trip {
                cell.trip = trip
            }
            cell.isUserInteractionEnabled = false
            return cell
        }
        
        if indexPath.section == 1  && indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddACrumbCell", for: indexPath) as! AddACrumbTableViewCell
            if let placeArray = array as? [[Place]] {
                if placeArray.count > 0 {
                    cell.tripHasCrumbs = true
                } else {
                    cell.tripHasCrumbs = false
                }
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        cell.selectionStyle = .none
        
        guard let placeArray = array as? [[Place]] else { return UITableViewCell() }
        let place = placeArray[indexPath.section - 2][indexPath.row]
        
        cell.place = place
        
        return cell
    }
}

extension TripDetailViewController: UITableViewDelegate {
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 1 {
            guard let placeArray = array as? [[Place]],
                let firstItemInArray = placeArray[section - 2].first,
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
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == 0 && indexPath.section == 0 || indexPath.row == 0 && indexPath.section == 1  {
            return UITableViewCellEditingStyle.none
        }
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let placeArray = array as? [[Place]] else { return }
            let place = placeArray[indexPath.section - 2][indexPath.row]
            PlaceController.shared.delete(place: place)
            setUpArrays()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            guard let addPlaceVC = sb.instantiateViewController(withIdentifier: "addAPlace") as? CreateNewPlaceTableViewController else { return }
            
            guard let trip = trip else { return }
            
            addPlaceVC.trip = trip
            
            self.present(addPlaceVC, animated: true, completion: nil)
        }
    }
}
