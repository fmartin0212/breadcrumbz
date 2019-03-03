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
    
    var trip: Trip? {
        didSet {
            loadViewIfNeeded()
            updateViws()
        }
    }
    
    var places: [Place] {
        guard let trip = trip,
            let placesSet = trip.places,
            let places = placesSet.allObjects as? [Place]
            else { return [] }
        return places
    }
    
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
       return places.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "crumbCell", for: indexPath) as? CrumbTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        if indexPath.row == places.count {
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
        let place = places[indexPath.row]
        cell.number = number
        cell.crumb = place
        
        return cell
    }
}

extension TripDetailVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == places.count {
            let createCrumbVC = AddCrumbViewController(nibName: "AddCrumb", bundle: nil)
            createCrumbVC.trip = trip
            self.present(createCrumbVC, animated: true, completion: nil)
            return
        }
        let crumb = places[indexPath.row]
        let crumbDetailVC = UIStoryboard.main.instantiateViewController(withIdentifier: "crumbDetailVC") as! PlaceDetailTableViewController
        crumbDetailVC.place = crumb
        self.navigationController?.pushViewController(crumbDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension TripDetailVC {
    
    func updateViws() {
        guard let trip = trip else { return }
        tripNameLabel.text = trip.name
        
        if let photo = trip.photo?.photo {
            tripImageView.image = UIImage(data: photo as Data)
        } else {
            tripImageView.image = UIImage(named: "map")
        }
        
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = "\((trip.startDate as Date).short()) - "
        tripEndDateLabel.text = (trip.endDate as Date).short()
    }
    
    func formatViews() {
//        lineViewSeparator.formatLine()
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
            TripController.shared.share(trip: trip, withReceiver: receiver, completion: { (success) in
                self.disableLoadingState(loadingView)
            })
        }
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
