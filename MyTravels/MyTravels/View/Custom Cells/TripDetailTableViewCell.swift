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
    @IBOutlet var tripDescriptionTextView: UITextView!
    
    // MARK: - Other Functions
    func updateTripDetail() {
        
        guard let trip = trip,
            let tripName = trip.name,
            let startDate = trip.startDate,
            let endDate = trip.endDate,
            let tripDescription = trip.tripDescription
            else { return }
        
        tripNameLabel.text = tripName
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = "\(shortDateString(date: startDate as Date)) -"
        tripEndDateLabel.text = shortDateString(date: endDate as Date)
//        tripDescriptionTextView.text = tripDescription
        tripDescriptionLabel.text = tripDescription
        
    }
    
    func updateSharedTripDetail() {
        guard let sharedTrip = sharedTrip else { return }
        
        tripLocationLabel.text = sharedTrip.location
        tripStartDateLabel.text = "\(shortDateString(date: sharedTrip.startDate as Date)) -"
        tripEndDateLabel.text = "\(shortDateString(date: sharedTrip.endDate as Date))"
        
    }
    
    func shortDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: date)
        
        return date
        
    }
}
