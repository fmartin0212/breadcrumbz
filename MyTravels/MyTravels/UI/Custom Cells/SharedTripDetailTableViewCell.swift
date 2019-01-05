//
//  SharedTripDetailTableViewCell.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/14/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedTripDetailTableViewCell: UITableViewCell {

    // MARK: - Properties
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
    func updateSharedTripDetail() {
        guard let sharedTrip = sharedTrip else { return }
        
        tripNameLabel.text = sharedTrip.name
        tripLocationLabel.text = sharedTrip.location
        tripStartDateLabel.text = "\(shortDateString(date: sharedTrip.startDate as Date)) -"
        tripEndDateLabel.text = "\(shortDateString(date: sharedTrip.endDate as Date))"
        tripDescriptionLabel.text = sharedTrip.description
        
    }
    
    func shortDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: date)
        
        return date
        
    }
}
