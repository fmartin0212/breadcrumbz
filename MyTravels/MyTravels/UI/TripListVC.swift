//
//  TripListVC.swift
//  MyTravels
//
//  Created by Frank Martin on 3/9/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit
import CoreData

final class TripListVC: UIViewController {

    // MARK: - Constants & Variables
    
    @IBOutlet weak var tableView: UITableView!
    let tripObjectManager = TripObjectManager()
    lazy var refreshControl = UIRefreshControl()
    var profileButton: UIButton?
    var emptyTripStateView: EmptyTripStateView?
    var trips: [TripObject] = []
    var state: State = .managed
    var deletedIndexPath: IndexPath?
    
    init(state: State, nibName: String) {
        self.state = state
        super.init(nibName: nibName, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentAddTripVC))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loadingView = self.enableLoadingState()
        setupViews()
        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
        tableView.separatorStyle = .none
        if state == .managed {
            TripController.shared.frc.delegate = self
        }
        tripObjectManager.fetchTrips(for: state) { (result) in
            switch result {
            case .success(let trips):
                self.trips = trips.sorted { ($0.startDate as Date) > ($1.startDate as Date)  }
                DispatchQueue.main.async { [weak self] in
                    self?.refreshViews()
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                print("error retrieving shared trips")
                }
            }
            DispatchQueue.main.async {
                self.disableLoadingState(loadingView)
            }
        }

//        for trip in TripController.shared.trips {
//            trip.uid = nil
//            CoreDataManager.save()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    @IBAction func addATripButtonTapped(_ sender: Any) {
        let addTripVC = AddTripVC(trip: nil, state: .add, nibName: "AddTrip")
        addTripVC.delegate = self
        self.present(addTripVC, animated: true, completion: nil)
    }
    
    @IBAction func addTripBarButtonItemTapped(_ sender: Any) {
        let addTripVC = AddTripVC(trip: nil, state: .add, nibName: "AddTrip")
        addTripVC.delegate = self
        self.present(addTripVC, animated: true, completion: nil)
    }
}

extension TripListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        // Cell and cell element formatting
        cell.selectionStyle = .none
        cell.crumbBackgroundView.layer.cornerRadius = cell.crumbBackgroundView.frame.width / 2
        cell.viewLineSeparator.formatLine()
        
        let trip = trips[indexPath.row]
        cell.trip = trip
        
        cell.crumbCountLabel.text = "\(trip.crumbCount)"
        cell.crumbsLabel.text = trip.crumbCount == 1 ? "Crumb" : "Crumbs"
        
        tripObjectManager.fetchPhoto(for: trip) { [weak cell] (result) in
            switch result {
            case .success(let photo):
                cell?.photo = photo
            case .failure(_):
                return
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let trip = trips[indexPath.row]
            presentDeleteAlert(for: trip as! Trip, indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {
        if state == .shared { return false }
        else { return true }
    }
}

extension TripListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell,
            let trip = cell.trip
            else { return }
        var photo: UIImage?
        if let tripPhoto = cell.photo {
            photo = tripPhoto
        }
        let tripDetailVC = TripDetailVC(trip: trip, photo: photo, state: state, nibName: "TripDetail")
        navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 344
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
    
    private func removeEmptyTripStateView() {
        DispatchQueue.main.async { [weak self] in
            guard let emptyTripStateView = self?.emptyTripStateView else { return }
            emptyTripStateView.removeFromSuperview()
        }
    }
    
    private func refreshViews() {
        let tripsIsEmpty = trips.count == 0 ? true : false
        if !tripsIsEmpty {
            removeEmptyTripStateView()
            return
        }
        if state == .shared && tripsIsEmpty == true {
            self.presentEmptyTripStateView()
        } else if state == .managed {
            TripController.shared.fetchAllTrips()
            if tripsIsEmpty == true {
                presentEmptyTripStateView()
            }
        }
    }
    
    private func setupViews() {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Poppins-Bold", size: 16)!, NSAttributedString.Key.foregroundColor : UIColor(red: 248/255, green: 89/255, blue: 89/255, alpha: 1)]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font : UIFont(name: "Poppins-Bold", size: 28)!, NSAttributedString.Key.foregroundColor : UIColor(red: 248/255, green: 89/255, blue: 89/255, alpha: 1)]

        if state == .shared {
            self.title = "Following"
            refreshControl.addTarget(self, action: #selector(fetchTrips), for: .valueChanged)
            tableView.addSubview(refreshControl)
            tableView.refreshControl = refreshControl
        } else {
            self.title = "My Trips"
            self.navigationItem.rightBarButtonItem = addButton
            TripController.shared.frc.delegate = self
        }
    }
    
    @objc private func presentAddTripVC() {
        let addTripVC = AddTripVC(trip: nil, state: .add, nibName: "AddTrip")
        self.present(addTripVC, animated: true, completion: nil)
    }
    
    @objc private func fetchTrips() {
        refreshControl.beginRefreshing()
        guard state == .shared else { return }
        tripObjectManager.fetchTrips(for: .shared) { (result) in
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                print("hi")
            }
            switch result {
            case .success(let trips):
                self.trips = trips.sorted { ($0.startDate as Date) > ($1.startDate as Date)  }
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    func presentDeleteAlert(for trip: Trip, _ indexPath: IndexPath) {
        let title = "Are you sure?"
        let message = trip.uid == nil ? "Your trip will be gone forever." : "Neither you nor your trip's followers will be able to see the trip again."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] (_) in
            let loadingView = self?.enableLoadingState()
            TripController.shared.delete(trip: trip) { (result) in
                DispatchQueue.main.async { [weak self] in
                    self?.trips.remove(at: indexPath.row)
                    self?.deletedIndexPath = indexPath
                    self?.disableLoadingState(loadingView!)
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension TripListVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            guard let deletedIndexPath = deletedIndexPath else { return }
            tableView.deleteRows(at: [deletedIndexPath], with: .fade)
            refreshViews()
        case .insert:
            guard let newIndexPath = newIndexPath,
                let trip = anObject as? Trip
                else { return }
            trips.append(trip)
            refreshViews()
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
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

extension TripListVC: AddTripVCDelegate {
    
    func saveButtonTapped(trip: TripObject) {
        DispatchQueue.main.async { [weak self] in
            self?.trips.append(trip)
            self?.refreshViews()
        }
    }
}
