//
//  TripListVC.swift
//  MyTravels
//
//  Created by Frank Martin on 3/9/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData

class TripListVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addATripButton: UIButton!
    
    // MARK: - Constants & Variables
    
    @IBOutlet weak var tableView: UITableView!
    var profileButton: UIButton?
    //    var fromSignUpVC = false
    //        didSet {
    //            let loadingView = enableLoadingState()
    //            fetchUserInfo { (success) in
    //                NotificationCenter.default.post(name: Constants.profilePictureUpdatedNotif, object: nil)
    //                self.disableLoadingState(loadingView)
    //            }
    //        }
    
    var isSharedTripsView: Bool = false
    lazy var tripDataSourceAndDelegate = TripDataSourceAndDelegate(self)
    lazy var sharedTripDataSourceAndDelegate = SharedTripDataSourceAndDelegate(self)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        loadViewIfNeeded()
        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
        
        // Set tableview properties
        tableView.separatorStyle = .none

        TripController.shared.frc.delegate = self
        
        // Set navigation bar properties
        TripController.shared.fetchAllTrips()
        
        if isSharedTripsView {
            tableView.dataSource = sharedTripDataSourceAndDelegate
            tableView.delegate = sharedTripDataSourceAndDelegate
        } else {
            tableView.dataSource = tripDataSourceAndDelegate
            tableView.delegate = tripDataSourceAndDelegate
        }
        
        for trip in TripController.shared.trips {
            trip.uid = nil
            CoreDataManager.save()
        }
        
        if TripController.shared.trips.count == 0 {
            //            self.presentNoTripsView()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let nib = UINib(nibName: "TripCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "TripCell")
//
//        // Set tableview properties
//        tableView.separatorStyle = .none
//
//        // Set delegates
//        //        tableView.dataSource = self
//        //        tableView.delegate = self
//        TripController.shared.frc.delegate = self
//
//        // Set navigation bar properties
//        TripController.shared.fetchAllTrips()
//
//        if isSharedTripsView {
//            tableView.dataSource = sharedTripDataSourceAndDelegate
//            tableView.delegate = sharedTripDataSourceAndDelegate
//        } else {
//            tableView.dataSource = tripDataSourceAndDelegate
//            tableView.delegate = tripDataSourceAndDelegate
//        }
//
//        for trip in TripController.shared.trips {
//            trip.uid = nil
//            CoreDataManager.save()
//        }
//
//        if TripController.shared.trips.count == 0 {
////            self.presentNoTripsView()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshTableView()
    }
    //
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        view.endEditing(true)
    //    }
    
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

extension TripListVC {
    
//    private func presentNoTripsView() {
//        view.addSubview(noTripsView)
//        noTripsView.isHidden = false
//        noTripsView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint(item: noTripsView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: noTripsView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: noTripsView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
//        NSLayoutConstraint(item: noTripsView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
//
//        self.navigationItem.rightBarButtonItem = nil
//        addATripButton.clipsToBounds = true
//        addATripButton.layer.cornerRadius = 25
//    }
    
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
    
    func refreshTableView() {
        if isSharedTripsView {
            
        } else {
            TripController.shared.fetchAllTrips()
            if TripController.shared.trips.count > 0 {
//                noTripsView.removeFromSuperview()
               
            }
        }
    }
}

extension TripListVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            guard let trips = TripController.shared.frc.fetchedObjects else { return }
            if trips.count == 0 {
//                presentNoTripsView()
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

