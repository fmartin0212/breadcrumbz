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
    @IBOutlet var tripLocationLabel: UILabel!
    @IBOutlet var tripStartDateLabel: UILabel!
    @IBOutlet var tripEndDateLabel: UILabel!
    
    // MARK: - Other Functions
    func updateTripDetail() {
        guard let trip = trip,
            let startDate = trip.startDate,
            let endDate = trip.endDate
            else { return }
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = "\(shortDateString(date: startDate as Date)) -"
        tripEndDateLabel.text = shortDateString(date: endDate as Date)
        
    }
    
    func updateSharedTripDetail() {
        guard let sharedTrip = sharedTrip
        else { return }
        tripLocationLabel.text = sharedTrip.location
        tripStartDateLabel.text = "\(shortDateString(date: sharedTrip.startDate as Date)) -"
        tripStartDateLabel.text = "\(shortDateString(date: sharedTrip.endDate as Date)) -"
        
    }
    
    func shortDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: date)
        
        return date
        
    }
}
