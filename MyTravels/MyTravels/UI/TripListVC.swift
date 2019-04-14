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
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    var profileButton: UIButton?
    lazy var tripDataSourceAndDelegate = TripDataSourceAndDelegate(self)
    lazy var sharedTripDataSourceAndDelegate = SharedTripDataSourceAndDelegate(self)
    var emptyTripStateView: EmptyTripStateView?
    var state: State = .managed
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddTripVC))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
        if state == .shared {
            self.title = "Shared"
            tableView.dataSource = sharedTripDataSourceAndDelegate
            tableView.delegate = sharedTripDataSourceAndDelegate
        } else {
            self.title = "My Trips"
            self.navigationItem.rightBarButtonItem = addButton
            tableView.dataSource = tripDataSourceAndDelegate
            tableView.delegate = tripDataSourceAndDelegate
            TripController.shared.frc.delegate = self
            TripController.shared.fetchAllTrips()
        }
        
        for trip in TripController.shared.trips {
            trip.uid = nil
            CoreDataManager.save()
        }
        
        refreshViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.prefersLargeTitles = true
        refreshViews()
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
    
    private func presentEmptyTripStateView() {
        let emptyTripStateView = UINib(nibName: "EmptyTripStateView", bundle: nil).instantiate(withOwner: nil, options: nil).first! as! EmptyTripStateView
        emptyTripStateView.state = state
        view.addSubview(emptyTripStateView)
        emptyTripStateView.isHidden = false
        emptyTripStateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint(item: emptyTripStateView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyTripStateView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyTripStateView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: emptyTripStateView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        
        self.emptyTripStateView = emptyTripStateView
        self.emptyTripStateView?.delegate = self
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
    
    func refreshViews() {
        if state == .shared {
            if SharedTripsController.shared.sharedTrips.count == 0 {
                self.navigationItem.rightBarButtonItem = nil
                self.presentEmptyTripStateView()
            }
        } else {
            TripController.shared.fetchAllTrips()
            if TripController.shared.trips.count > 0 {
                if let emptyTripStateView = emptyTripStateView {
                    emptyTripStateView.removeFromSuperview()
                }
            } else {
                self.presentEmptyTripStateView()
            }
        }
    }
    
    @objc private func presentAddTripVC() {
        let addTripVC = AddTripViewController(nibName: "AddTrip", bundle: nil)
        self.present(addTripVC, animated: true, completion: nil)
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
//                presentemptyTripStateView()
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

extension TripListVC: UISearchBarDelegate {
   
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
              searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

extension TripListVC: EmptyTripStateViewDelegate {
    func getStartedButtonTapped() {
        self.presentAddTripVC()
    }
}
