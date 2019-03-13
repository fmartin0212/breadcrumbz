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
    @IBOutlet weak var tripDescription: UILabel!
    @IBOutlet weak var crumbsTableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var addCrumbButton: UIButton!
    
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
        self.navigationItem.largeTitleDisplayMode = .never
        actionButton.layer.cornerRadius = actionButton.frame.width / 2
        actionButton.clipsToBounds = true
        
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
        
        if let trip = trip as? Trip,
            let placesSet = trip.places,
            let places = placesSet.allObjects as? [Place] {
            self.crumbs = places
        }
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        presentShareAlertController()
    }
    @IBAction func addCrumbButtonTapped(_ sender: Any) {
        let createCrumbVC = AddCrumbViewController(nibName: "AddCrumb", bundle: nil)
        createCrumbVC.trip = trip
        self.present(createCrumbVC, animated: true, completion: nil)
    }
}

extension TripDetailVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crumbs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "crumbCell", for: indexPath) as? CrumbTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        let crumb = crumbs[indexPath.row]
        cell.crumb = crumb
        return cell
    }
}

extension TripDetailVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let crumb = crumbs[indexPath.row]
        let crumbDetailVC = UIStoryboard.main.instantiateViewController(withIdentifier: "crumbDetailVC") as! PlaceDetailTableViewController
        crumbDetailVC.crumb = crumb
        self.navigationController?.pushViewController(crumbDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

extension TripDetailVC {
    
    private func updateViews() {
        
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
        tripDescription.text = "My really really long trip description. My really really long trip description.My really really long trip description.My really really long trip description.My really really long trip description.My really really long trip description."
        
    }
    
    private func formatViews() {
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        
        title = trip?.name
        
        if trip is SharedTrip {
            addCrumbButton.isHidden = true
        } else {
            addCrumbButton.layer.cornerRadius = addCrumbButton.frame.width / 2
            addCrumbButton.layer.borderColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
            addCrumbButton.layer.borderWidth = 1.5
        
        }
    }
    
    private func presentShareAlertController() {
        
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
