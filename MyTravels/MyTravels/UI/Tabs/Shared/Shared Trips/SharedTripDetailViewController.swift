//
//  SharedTripDetailViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedTripDetailViewController: UIViewController {
    
    // MARK: - Properties
    var sharedTrip: SharedTrip?
    var sharedPlaces: [[SharedPlace]]?
    let rightBarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("...", for: .normal)
//        let attributedString = NSAttributedString(string: "...", attributes: [NSAttributedStringKey.font : UIFont(name: "AvenirNext", size: 22)])
//        button.setAttributedTitle(attributedString, for: .normal)
//        button.setAttributedTitle(attributedString, for: .highlighted)
        return button
    }()
    
    // MARK: - IBOutlets
    @IBOutlet var sharedTripPhotoImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        rightBarButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        guard let sharedTrip = sharedTrip else { return }
    
        // Set shared trip photo
        var tripPhoto = UIImage()
        guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
        tripPhoto = tripPhotoPlaceholderImage
        
        if let photo = sharedTrip.photo {
            tripPhoto = photo
        }

        sharedTripPhotoImageView.image = tripPhoto
        
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
    
    // MARK: - Functions
    func setUpArrays() {
        
        guard let sharedTrip = sharedTrip else { return }
        
        let places = sharedTrip.places
        
        var array: [[SharedPlace]] = []
        var lodgingArray: [SharedPlace] = []
        var restaurantsArray: [SharedPlace] = []
        var activitiesArray: [SharedPlace] = []
        
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

        self.sharedPlaces = array
        
        tableView.reloadData()
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSharedPlaceDetailTableViewController" {
           
            guard let sharedTrip = sharedTrip,
                let sharedPlaces = sharedPlaces,
                let destinationVC = segue.destination as? SharedPlaceDetailTableViewController,
                let indexPath = tableView.indexPathForSelectedRow
                else { return }
            
            let sharedPlace = sharedPlaces[indexPath.section - 1][indexPath.row]
            destinationVC.sharedTrip = sharedTrip
            destinationVC.sharedPlace = sharedPlace
        }
    }
}

extension SharedTripDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
   
        // Use shared places array as datasource
        guard let sharedPlacesArray = sharedPlaces else { return 0 }
        return sharedPlacesArray.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section > 0 {
            // Use shared places array as datasource
            guard let sharedPlacesArray = sharedPlaces,
                let firstItemInArray = sharedPlacesArray[section - 1].first
                else { return UIView() }
            
            if firstItemInArray.type == "Lodging" {
                let text = "  Lodging"
                return sectionHeaderLabelWith(text: text)
                
            } else if firstItemInArray.type == "Restaurant" {
                let text = "  Restaurants"
                return sectionHeaderLabelWith(text: text)
                
            } else if firstItemInArray.type == "Activity" {
                let text = "  Activities"
                return sectionHeaderLabelWith(text: text)
            }
            return UIView()
        }
        return UIView()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section  == 0 {
            return 1
        }
        
        if section > 0 {
        
            guard let sharedPlaces = sharedPlaces else { return 0 }
            return sharedPlaces[section - 1].count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SharedTripDetailCell") as! SharedTripDetailTableViewCell
            cell.sharedTrip = sharedTrip
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        cell.selectionStyle = .none
        
        guard let sharedPlacesArray = sharedPlaces else { return UITableViewCell() }
        let sharedPlace = sharedPlacesArray[indexPath.section - 1][indexPath.row]
        
        cell.sharedPlace = sharedPlace
        
        return cell
        
    }
}

extension SharedTripDetailViewController {
    
    private func blockUserWith(username: String, completion: @escaping (Bool) -> Void) {
        guard let sharedTrip = sharedTrip else { completion(false) ; return }
        
        InternalUserController.shared.blockUserWith(username: username) { (success) in
            if success {
                completion(true)
            } else {
                // Handle error UI
            }
        }
    }
    
    @objc func actionButtonTapped() {
        
        let actionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockUserAction = UIAlertAction(title: "Block user", style: .default) { (_) in
            let confirmationAlertController = UIAlertController(title: nil, message: "Are you sure you want to block this user?", preferredStyle: .alert)
            
            let blockAction = UIAlertAction(title: "Block", style: .destructive, handler: { (_) in
                
                let loadingView = self.enableLoadingState()
                loadingView.loadingLabel.text = "Blocking user"
                
                InternalUserController.shared.blockUserWith(username: self.sharedTrip!.creatorUsername, completion: { (success) in
                    if success {
                        DispatchQueue.main.async {
                            loadingView.removeFromSuperview()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            confirmationAlertController.addAction(blockAction)
            confirmationAlertController.addAction(cancelAction)
            
            self.present(confirmationAlertController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionAlertController.addAction(blockUserAction)
        actionAlertController.addAction(cancelAction)
        self.present(actionAlertController, animated: true, completion: nil)
        
    }
}
