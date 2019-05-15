//
//  TripTableViewCell
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {
    
    // MARK: - Constants & Variables
    
    var trip: TripObject? {
        didSet {
            guard let trip = trip else { return }
            updateViews(for: trip)
        }
    }

    var photo: UIImage? {
        didSet {
            guard let photo = photo else { return }
            updateImageView(with: photo)
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var crumbBackgroundView: UIView!
    @IBOutlet weak var crumbCountLabel: UILabel!
    @IBOutlet weak var viewLineSeparator: UIView!
    
    }

extension TripTableViewCell {
    
    func updateViews(for trip: TripObject) {
        tripImageView.layer.cornerRadius = 12
        tripImageView.clipsToBounds = true
        tripNameLabel.text = trip.name
        tripLocationLabel.text = trip.location
        tripStartDateLabel.text = (trip.startDate as Date).short() + " - "
        tripEndDateLabel.text = (trip.endDate as Date).short()
    }
    
    func updateImageView(with photo: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.tripImageView.image = photo
        }
    }
}
