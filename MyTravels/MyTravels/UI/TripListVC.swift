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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let tripObjectManager = TripObjectManager()
    lazy var activityIndicator = UIActivityIndicatorView()
    var profileButton: UIButton?
    var emptyTripStateView: EmptyTripStateView?
    var trips: [TripObject] = []
    var state: State = .managed

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
        setupViews()
        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
        tableView.separatorStyle = .none
        TripController.shared.frc.delegate = self
        tripObjectManager.fetchTrips(for: state) { (result) in
            switch result {
            case .success(let trips):
                self.trips = trips
                DispatchQueue.main.async { [weak self] in
                    self?.refreshViews()
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.presentStandardAlertController(withTitle: "Uh Oh", message: error.localizedDescription)
                }
            }
        }

        for trip in TripController.shared.trips {
            trip.uid = nil
            CoreDataManager.save()
        }
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let trip = trips[indexPath.row]
            trips.remove(at: indexPath.row)
            TripController.shared.delete(trip: trip as! Trip)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
    
    private func presentActivityIndicator() {
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    private func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
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
        if state == .shared {
            self.title = "Shared"
            
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
}

extension TripListVC: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
            refreshViews()
        case .insert:
            guard let newIndexPath = newIndexPath,
            let trip = anObject as? Trip
            else { return }
            trips.append(trip)
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
            self?.refreshViews()
        }
    }
}
