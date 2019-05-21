//
//  TripDetailVC.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/18/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

final class TripDetailVC: UIViewController {

    // MARK: - Constants & Variables
    
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripDescription: UILabel!
    @IBOutlet weak var crumbsTableView: UITableView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var addCrumbButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    private let crumbObjectManager = CrumbObjectManager()
    private var trip: TripObject
    private var photo: UIImage?
    private var crumbs: [CrumbObject] = []
    private let state: State
    private lazy var editBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        return barButtonItem
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(trip: TripObject, photo: UIImage?, state: State, nibName: String) {
        self.trip = trip
        self.photo = photo
        self.state = state
        super.init(nibName: nibName, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        actionButton.layer.cornerRadius = actionButton.frame.width / 2
        actionButton.clipsToBounds = true
        
        crumbObjectManager.fetchCrumbs(for: trip) { [weak self] (result) in
            switch result {
            case .success(let crumbs):
                DispatchQueue.main.async {
                    self?.crumbs = crumbs
                    self?.crumbsTableView.reloadData()
                    guard let numberOfRows = self?.crumbsTableView.numberOfRows(inSection: 0) else { return }
                    self?.tableViewHeightConstraint.constant = CGFloat(numberOfRows * 110)
                    self?.view.layoutIfNeeded()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.presentStandardAlertController(withTitle: "Uh Oh!", message: error.rawValue)
                }
            }
        }
        
        let crumbTableViewCell = UINib(nibName: "CrumbTableViewCell", bundle: nil)
        crumbsTableView.register(crumbTableViewCell, forCellReuseIdentifier: "crumbCell")
        
        formatViews()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let trip = trip as? Trip,
            let placesSet = trip.places,
            let places = placesSet.allObjects as? [Place] {
            self.crumbs = places
        }
        crumbsTableView.reloadData()
        tableViewHeightConstraint.constant = CGFloat(crumbsTableView.numberOfRows(inSection: 0) * 110)
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        if trip is Trip {
            presentShareAlertController()
        } else {
            actionButtonTapped()
        }
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
        let image = UIImage(named: (crumb.type?.rawValue)!)
        cell.crumbImageView.image = image
        return cell
    }
}

extension TripDetailVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let crumb = crumbs[indexPath.row]
        let crumbDetailVC = CrumbDetailVC(crumb: crumb, nibName: "CrumbDetail")
        crumbDetailVC.crumb = crumb
        
        self.navigationController?.pushViewController(crumbDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension TripDetailVC {
    
    private func updateViews() {
        if let photo = photo {
            tripImageView.image = photo
            tripImageView.clipsToBounds = true
            tripImageView.contentMode = .scaleAspectFill
        }
        tripNameLabel.text = trip.name
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = "\((trip.startDate as Date).short()) - "
        tripEndDateLabel.text = (trip.endDate as Date).short()
        tripDescription.text = trip.tripDescription
    }
    
    private func formatViews() {
        title = trip.name
        
        if trip is SharedTrip {
            addCrumbButton.isHidden = true
            actionButton.setImage(UIImage(named: "more"), for: .normal)
        } else {
            addCrumbButton.layer.cornerRadius = addCrumbButton.frame.width / 2
            addCrumbButton.layer.borderColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
            addCrumbButton.layer.borderWidth = 1.5
            navigationItem.rightBarButtonItem = editBarButtonItem
        }
    }
    
    private func presentShareAlertController() {
        
        let alertController = UIAlertController(title: "Share trip", message: "Enter a username below to share your trip", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] (action) in
            
            guard let receiver = alertController.textFields?[0].text else { return }
            let loadingView = self?.enableLoadingState()
            loadingView?.loadingLabel.text = "Sharing"
            TripController.shared.share(trip: self?.trip as! Trip, withReceiver: receiver, completion: { (success) in
                DispatchQueue.main.async { [weak self] in
                    guard let loadingView = loadingView else { return }
                    self?.disableLoadingState(loadingView)
                }
            })
        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped() {
        guard let trip = trip as? Trip else { return }
        let editTripVC = AddTripVC(trip: trip, state: .edit, nibName: "AddTrip")
        present(editTripVC, animated: true, completion: nil)
    }
    
    @objc private func actionButtonTapped() {
        
        let actionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let blockUserAction = UIAlertAction(title: "Block user", style: .default) { (_) in
            let confirmationAlertController = UIAlertController(title: nil, message: "Are you sure you want to block this user?", preferredStyle: .alert)
            
            let blockAction = UIAlertAction(title: "Block", style: .destructive, handler: { (_) in
                guard let sharedTrip = self.trip as? SharedTrip else { return }
                let loadingView = self.enableLoadingState()
                loadingView.loadingLabel.text = "Blocking user"
                
                InternalUserController.shared.blockUserWith(creatorID: sharedTrip.creatorID, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        self.presentStandardAlertController(withTitle: "Uh Oh!", message: error.rawValue)
                    case .success(_):
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
