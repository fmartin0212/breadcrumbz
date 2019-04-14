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
        let tripDetailCellNib = UINib(nibName: "TripDetailCell", bundle: nil)
        tableView.register(tripDetailCellNib, forCellReuseIdentifier: "TripDetailCell")
        
        tableView.estimatedRowHeight = 134
        tableView.rowHeight = UITableView.automaticDimension
        
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
            if InternalUserController.shared.loggedInUser == nil {
                self.presentCreateAccountAlert()
                return
            }
            
            self.presentShareAlertController()
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
            guard let placesSet = trip.places,
                let places = placesSet.allObjects as? [Place] else { return }
            
            var array: [[Place]] = []
            
            let lodging = places.filter { $0.type == .lodging }
            let restaurants = places.filter { $0.type == .restaurant }
            let activities = places.filter { $0.type == .activity }
            
            if lodging.count > 0 {
                array.append(lodging)
            }
            
            if restaurants.count > 0 {
                array.append(restaurants)
            }
            
            if activities.count > 0 {
                array.append(activities)
            }
            
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
                let receiver = alertController.textFields?[0].text
                else { return }
            let loadingView = self.enableLoadingState()
            loadingView.loadingLabel.text = "Sharing"
            TripController.shared.share(trip: trip, withReceiver: receiver, completion: { (success) in
                self.disableLoadingState(loadingView)
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
            let createAccountVC = UIStoryboard.onboarding.instantiateViewController(withIdentifier: "SignUp")
            
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
//            destinationVC.crumb = place
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 1 {
            guard let placeArray = array as? [[Place]],
                let firstItemInArray = placeArray[section - 2].first
                else { return UIView() }
            
            var text = ""
            switch firstItemInArray.type {
            case .lodging?:
                text = "  Lodging"
            case .restaurant?:
                text = "  Restaurants"
            case .activity?:
                text = "  Activities"
            default:
                break
            }
            return sectionHeaderLabelWith(text: text)
          
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 && indexPath.section == 0 || indexPath.row == 0 && indexPath.section == 1  {
            return UITableViewCell.EditingStyle.none
        }
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            guard let placeArray = array as? [[Place]] else { return }
            let place = placeArray[indexPath.section - 2][indexPath.row]
            PlaceController.shared.delete(place: place)
            setUpArrays()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            
            let addPlaceVC = UIStoryboard.main.instantiateViewController(withIdentifier: "addAPlace") as! CreateNewPlaceTableViewController
            
            guard let trip = trip else { return }
            
            addPlaceVC.trip = trip
            
            self.present(addPlaceVC, animated: true, completion: nil)
        }
    }
}
