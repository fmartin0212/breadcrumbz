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
        tableView.delegate = self
        
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

extension SharedTripsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return SharedTripsController.shared.sharedTrips[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        cell.selectionStyle = .none
        
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.section][indexPath.row]
        cell.sharedTrip = sharedTrip
        
        return cell
        
        }
    }
