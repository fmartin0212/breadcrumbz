//
//  TripsListViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData

class TripsListViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet var noTripsView: UIView!
    @IBOutlet var addTripBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addATripButton: UIButton!
    
    // MARK: - Constants & Variables
    
    var profileButton: UIButton?
    var fromSignUpVC = false {
        didSet {
            let loadingView = enableLoadingState()
            fetchUserInfo { (success) in
                NotificationCenter.default.post(name: Constants.profilePictureUpdatedNotif, object: nil)
                self.disableLoadingState(loadingView)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        TripController.shared.frc.delegate = self
        
        // Set navigation bar properties
        addTripBarButtonItem.format()
        TripController.shared.fetchAllTrips()

        for trip in TripController.shared.trips {
            trip.uid = nil
            CoreDataManager.save()
        }
    
        if TripController.shared.trips.count == 0 {
            self.presentNoTripsView()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserInfo), name: Constants.userLoggedInNotif, object: nil)
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
    
    @IBAction func addATripButtonTapped(_ sender: Any) {
        let addTripVC = AddTripViewController(nibName: "AddTrip", bundle: nil)
        self.present(addTripVC, animated: true, completion: nil)
//        performSegue(withIdentifier: "addATripSegue", sender: nil)
        
    }
    
    @IBAction func addTripBarButtonItemTapped(_ sender: Any) {
        let addTripVC = AddTripViewController(nibName: "AddTrip", bundle: nil)
        self.present(addTripVC, animated: true, completion: nil)
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
    
    private func fetchUserInfo(completion: @escaping (Bool) -> Void) {
        
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { completion(false) ; return }
        SharedTripsController.shared.fetchSharedTrips { (success) in
            if success {
                NotificationCenter.default.post(name: Constants.sharedTripsReceivedNotif, object: nil)
                if let photoURL = loggedInUser.photoURL {
                    InternalUserController.shared.fetchProfilePhoto(from: photoURL, completion: { (photo) in
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    })
                }
            } else { completion(false) }
        }
    }
    
    @objc func loadUserInfo() {
        let loadingView = enableLoadingState()
        fetchUserInfo { (success) in
            NotificationCenter.default.post(name: Constants.profilePictureUpdatedNotif, object: nil)
            self.disableLoadingState(loadingView)
        }
    }
}

extension TripsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trips = TripController.shared.frc.fetchedObjects else { return 0 }
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        
        // Cell and cell element formatting
        cell.selectionStyle = .none
        cell.crumbBackgroundView.layer.cornerRadius = cell.crumbBackgroundView.frame.width / 2
        cell.viewLineSeparator.formatLine()
        
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
        
//        let tripDetailVC: TripDetailVC = UIViewController(nibName: <#T##String?#>, bundle: <#T##Bundle?#>)
        let tripDetailVC = TripDetailVC(nibName: "TripDetail", bundle: nil)
        
//        guard let tripDetailVC = UIStoryboard.main.instantiateViewController(withIdentifier: "tripDetailVC") as? TripDetailViewController else { return }
        
        tripDetailVC.trip = trip
        
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 344
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


