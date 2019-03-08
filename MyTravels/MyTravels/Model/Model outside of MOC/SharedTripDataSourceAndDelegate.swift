//
//  SharedTripDataSource.swift
//  MyTravels
//
//  Created by Frank Martin on 3/8/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedTripDataSourceAndDelegate: NSObject {
    private let viewController: UIViewController
    
    init(_ viewController:termina UIViewController) {
        self.viewController = viewController
    }
}

extension SharedTripDataSourceAndDelegate: UITableViewDataSource {
  
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

extension SharedTripDataSourceAndDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let sharedTripDetailVC = sb.instantiateViewController(withIdentifier: "sharedTripDetail") as? SharedTripDetailViewController else { return }
        sharedTripDetailVC.sharedTrip = sharedTrip
        viewController.navigationController?.pushViewController(sharedTripDetailVC, animated: true)
    }
}
