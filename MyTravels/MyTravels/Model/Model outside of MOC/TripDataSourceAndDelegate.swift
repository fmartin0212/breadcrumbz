//
//  TripDataSource.swift
//  MyTravels
//
//  Created by Frank Martin on 3/8/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripDataSourceAndDelegate: NSObject {
    let viewController: UIViewController
    
    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
}

extension TripDataSourceAndDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let trips = TripController.shared.frc.fetchedObjects else { return 0 }
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        
        // Cell and cell element formatting
        cell.selectionStyle = .none
        cell.crumbBackgroundView.layer.cornerRadius = cell.crumbBackgroundView.frame.width / 2
        cell.viewLineSeparator.formatLine()
        
        guard let trips = TripController.shared.frc.fetchedObjects else { return UITableViewCell() }
        let trip = trips[indexPath.row]
        cell.trip = trip
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let trips = TripController.shared.frc.fetchedObjects else { return }
            let trip = trips[indexPath.row]
            TripController.shared.delete(trip: trip)
        }
    }
    
}

extension TripDataSourceAndDelegate: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = TripController.shared.trips[indexPath.row]
        let tripDetailVC = TripDetailVC(nibName: "TripDetail", bundle: nil)
        tripDetailVC.trip = trip
        viewController.navigationController?.pushViewController(tripDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 344
    }
}
