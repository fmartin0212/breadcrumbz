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
    
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func refresh() {
        SharedTripsController.shared.fetchSharedTrips { (success) in
            if success {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSharedTripDetailViewSegue" {
            guard let destinationVC = segue.destination as? SharedTripDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow
                else { return }
            let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
            destinationVC.sharedTrip = sharedTrip
            
        }
    }
    
    @IBAction func profileBarButtonItemTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "profileVC")
        UIView.animate(withDuration: 2) {
            self.present(profileVC, animated: true, completion: nil)
        }
    }
}

extension SharedTripsListViewController: UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return SharedTripsController.shared.sharedTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        cell.selectionStyle = .none
        
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]

        cell.sharedTrip = sharedTrip
        
        return cell
        
        }
    }

extension SharedTripsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]

        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let sharedTripDetailVC = sb.instantiateViewController(withIdentifier: "sharedTripDetail") as? SharedTripDetailViewController else { return }
        sharedTripDetailVC.sharedTrip = sharedTrip
        self.navigationController?.pushViewController(sharedTripDetailVC, animated: true)
    }
}
