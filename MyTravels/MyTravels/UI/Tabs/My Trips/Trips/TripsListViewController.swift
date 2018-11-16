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
    
    // MARK: - IBOutlets
    
    @IBOutlet var noTripsView: UIView!
    @IBOutlet var addTripBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addATripButton: UIButton!
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    
    // MARK: - Constants & Variables
    var profileButton: UIButton?
    
    // FIXME - Put this in a 'Constants' file
    static let profilePictureUpdatedNotification = Notification.Name("profilePictureUpdatedNotification")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
     
        setupLeftBarButton()
        
        // Set tableview properties
        tableView.separatorStyle = .none
       
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        TripController.shared.frc.delegate = self

        // Set navigation bar properties
        navigationController?.navigationBar.prefersLargeTitles = true
        addTripBarButtonItem.format()
        TripController.shared.fetchAllTrips()
        if TripController.shared.trips.count == 0 {
            self.presentNoTripsView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicture), name: TripsListViewController.profilePictureUpdatedNotification, object: nil)
        
//        updateProfilePicture()
        
        InternalUserController.shared.blockUserWith(username: "frank") { (success) in

        }
        
    }
    
    @objc func updateProfilePicture() {
        let image = InternalUserController.shared.loggedInUser!.photo
        let resizedImage = image?.resize(to: CGSize(width: 35, height: 35))
        
        DispatchQueue.main.async {
            self.profileButton?.setImage(resizedImage, for: .normal)
            self.profileButton?.clipsToBounds = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        TripController.shared.fetchAllTrips()
        if TripController.shared.trips.count > 0 {
                noTripsView.removeFromSuperview()
                self.navigationItem.rightBarButtonItem = addTripBarButtonItem
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func profileButtonTapped() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "profileVC")
        UIView.animate(withDuration: 2) {
            self.present(profileVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func addATripButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "addATripSegue", sender: nil)
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

extension TripsListViewController {
    
    private func presentNoTripsView() {
        view.addSubview(noTripsView)
        noTripsView.isHidden = false
        noTripsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: noTripsView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: noTripsView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: noTripsView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: noTripsView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        self.navigationItem.rightBarButtonItem = nil
        addATripButton.clipsToBounds = true
        addATripButton.layer.cornerRadius = 25
    }
    
    private func setupLeftBarButton() {
        let button = UIButton(type: .custom)
        let image = InternalUserController.shared.loggedInUser?.photo != nil ? InternalUserController.shared.loggedInUser?.photo : UIImage(named: "user")
        let resizedImage = image?.resize(to: CGSize(width: 35, height: 35))
        button.setImage(resizedImage, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 17.5
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        profileButton = button
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
    }
}

extension TripsListViewController: UITableViewDataSource {
    
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

extension TripsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = TripController.shared.trips[indexPath.row]
        
        guard let tripDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tripDetailVC") as? TripDetailViewController else { return }
        
        tripDetailVC.trip = trip
        
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
}

extension TripsListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            guard let trips = TripController.shared.frc.fetchedObjects else { return }
            if trips.count == 0 {
                presentNoTripsView()
            }
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


