//
//  TripDetailTableViewCell.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/10/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripDetailTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var trip: Trip? {
        didSet {
            updateTripDetail()
        }
    }
    var sharedTrip: SharedTrip? {
        didSet {
            updateSharedTripDetail()
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripDescriptionLabel: UILabel!
    
    // MARK: - Other Functions
    
    func updateTripDetail() {
        
        guard let trip = trip
            else { return }
        
        tripNameLabel.text = trip.name
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = "\((trip.startDate as Date).short()) -"
        tripEndDateLabel.text = (trip.endDate as Date).short()
        tripDescriptionLabel.text = trip.tripDescription ?? ""
        
    }
    
    func updateSharedTripDetail() {
        guard let sharedTrip = sharedTrip else { return }
        
        tripLocationLabel.text = sharedTrip.location
        tripStartDateLabel.text = "\((sharedTrip.startDate as Date).short()) -"
        tripEndDateLabel.text = "\((sharedTrip.endDate as Date).short())"
        
    }
}
