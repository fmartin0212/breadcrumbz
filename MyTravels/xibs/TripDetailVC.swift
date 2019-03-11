//
//  TripDetailVC.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/18/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripDetailVC: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var lineViewSeparator: UIView!
    @IBOutlet weak var crumbsTableView: UITableView!
    lazy var shareBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(presentShareAlertController))
    }()
    
    // MARK: - Constants & Variables
    
    var trip: TripObject? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    var sharedTrip: SharedTrip? {
        didSet {
            SharedPlaceController.fetchPlaces(for: sharedTrip!) { (sharedCrumbs) in
                guard let sharedCrumbs = sharedCrumbs else { return }
                self.sharedCrumbs = sharedCrumbs
            }
        }
    }
    var sharedCrumbs: [SharedPlace] = [] {
        didSet {
            updateViews()
        }
    }

    var crumbs: [CrumbObject] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = shareBarButtonItem
        self.navigationItem.largeTitleDisplayMode = .never
        
        if let trip = trip as? Trip,
            let placesSet = trip.places,
            let places = placesSet.allObjects as? [Place] {
            self.crumbs = places
        } else {
            SharedPlaceController.fetchPlaces(for: trip! as! SharedTrip) { (sharedCrumbs) in
                if let sharedCrumbs = sharedCrumbs {
                    self.crumbs = sharedCrumbs
                }
            }
        }
        
        let crumbTableViewCell = UINib(nibName: "CrumbTableViewCell", bundle: nil)
        crumbsTableView.register(crumbTableViewCell, forCellReuseIdentifier: "crumbCell")
        
        crumbsTableView.dataSource = self
        crumbsTableView.delegate = self
        formatViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        crumbsTableView.reloadData()
    }
}

extension TripDetailVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _ = trip as? Trip else { return crumbs.count }
        return crumbs.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "crumbCell", for: indexPath) as? CrumbTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        
        if let _ = trip as? Trip {
            if indexPath.row == crumbs.count {
                cell.numberBackdropView.layer.cornerRadius = cell.numberBackdropView.frame.height / 2
                cell.numberBackdropView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                cell.numberBackdropView.layer.borderColor = #colorLiteral(red: 1, green: 0.4002141953, blue: 0.372333765, alpha: 1)
                cell.numberBackdropView.layer.borderWidth = 2
                cell.numberLabel.textColor = #colorLiteral(red: 1, green: 0.4002141953, blue: 0.372333765, alpha: 1)
                cell.numberLabel.text = "+"
                cell.nameLabel.text = "Add Crumb"
                cell.typeLabel.text = nil
                cell.accessoryLabel.text = nil
                
                return cell
            }
            let number = indexPath.row + 1
            let place = crumbs[indexPath.row]
            cell.number = number
            cell.crumb = place
            
            return cell
        }
        
        let number = indexPath.row
        let crumb = crumbs[indexPath.row]
        cell.number = number
        cell.crumb = crumb
        return cell
    }
}

extension TripDetailVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == crumbs.count {
            let createCrumbVC = AddCrumbViewController(nibName: "AddCrumb", bundle: nil)
            createCrumbVC.trip = trip
            self.present(createCrumbVC, animated: true, completion: nil)
            return
        }
        let crumb = crumbs[indexPath.row]
        let crumbDetailVC = UIStoryboard.main.instantiateViewController(withIdentifier: "crumbDetailVC") as! PlaceDetailTableViewController
        crumbDetailVC.crumb = crumb
        self.navigationController?.pushViewController(crumbDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension TripDetailVC {
    
    func updateViews() {
        
        guard let trip = trip else { return }
        if let managedTrip = trip as? Trip {
            if let managedPhoto = managedTrip.photo?.photo {
                tripImageView.image = UIImage(data: managedPhoto as Data)
            }
        } else if let nonManagedPhoto = sharedTrip?.photo {
            tripImageView.image = nonManagedPhoto
        } else {
            tripImageView.image = UIImage(named: "map")
        }
        
        tripNameLabel.text = trip.name
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = "\((trip.startDate as Date).short()) - "
        tripEndDateLabel.text = (trip.endDate as Date).short()
    }
    
    func formatViews() {
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        
        title = trip?.name
    }
    
    @objc private func presentShareAlertController() {
        
        let alertController = UIAlertController(title: "Share trip", message: "Enter a username below to share your trip", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            
            guard let trip = self.trip,
                let receiver = alertController.textFields?[0].text
                else { return }
            let loadingView = self.enableLoadingState()
            loadingView.loadingLabel.text = "Sharing"
            TripController.shared.share(trip: trip as! Trip, withReceiver: receiver, completion: { (success) in
                self.disableLoadingState(loadingView)
            })
        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
