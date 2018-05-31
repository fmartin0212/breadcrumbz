//
//  SharedTripsListViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedTripsListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
        // Set delegates
        tableView.dataSource = self
        
        
        // FIXME: - This should tell the user that they do not have an account or are not logged into their iCloud account. Prompt for account creation?
        // Check to see if there is a current user logged in, if not, present sign-up view
        if UserController.shared.loggedInUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createAccountViewController = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController")
            
            UIView.animate(withDuration: 0.75, animations: {
                self.present(createAccountViewController, animated: true, completion: nil)
            })
        }
        
        // Set navigation bar properties
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSharedTripDetailViewSegue" {
            guard let destinationVC = segue.destination as? SharedTripDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow
                else { return }
            let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.section][indexPath.row]
            destinationVC.sharedTrip = sharedTrip

        }
    }
}

extension SharedTripsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SharedTripsController.shared.sharedTrips.count > 0 ?  SharedTripsController.shared.sharedTrips.count : 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if SharedTripsController.shared.sharedTrips.count > 0 {
            if SharedTripsController.shared.sharedTrips[section].first?.isAcceptedTrip == false {
                return "Pending"
            }
            else if SharedTripsController.shared.sharedTrips[section].first?.isAcceptedTrip == true {
                return "Following"
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if SharedTripsController.shared.sharedTrips.count > 0 {
            return SharedTripsController.shared.sharedTrips[section].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        cell.selectionStyle = .none
        
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.section][indexPath.row]
        
        cell.sharedTrip = sharedTrip
        cell.indexPath = indexPath
        
        SharedTripsController.shared.fetchCreator(for: sharedTrip) { (user) in
            guard let user = user else { return }
            cell.user = user
        }
        
        cell.delegate = self
        
        return cell
        
        }
    }

extension SharedTripsListViewController: TripTableViewCellDelegate {
    
    func accepted(sharedTrip: SharedTrip, indexPath: IndexPath) {
        SharedTripsController.shared.accept(sharedTrip: sharedTrip, at: indexPath) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func denied(sharedTrip: SharedTrip, indexPath: IndexPath) {
        SharedTripsController.shared.deny(sharedTrip: sharedTrip, at: indexPath) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}
