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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set tableview properties
        tableView.separatorStyle = .none
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        
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
    
    @IBAction func profileBarButtonItemTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "profileVC")
        UIView.animate(withDuration: 2) {
            self.present(profileVC, animated: true, completion: nil)
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

extension SharedTripsListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.section][indexPath.row]
        guard let cell = tableView.cellForRow(at: indexPath) as? TripTableViewCell else { return }
        
        if sharedTrip.isAcceptedTrip == false {
            UIView.animate(withDuration: 0.10, animations: {
                cell.acceptButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }) { (_) in
                UIView.animate(withDuration: 0.10, animations: {
                    cell.acceptButton.transform = CGAffineTransform.identity
                }, completion: { (_) in
                   
                })
            }
             return
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let sharedTripDetailVC = sb.instantiateViewController(withIdentifier: "sharedTripDetail") as? SharedTripDetailViewController else { return }
        sharedTripDetailVC.sharedTrip = sharedTrip
        self.navigationController?.pushViewController(sharedTripDetailVC, animated: true)
    }
}
