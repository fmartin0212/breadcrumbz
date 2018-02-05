//
//  TripTableViewCell
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var trip: Trip? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    // Trip
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripRecommendationImageView: UIImageView!
    
    // MARK: - Functions
    func updateViews() {
        tripImageView.layer.cornerRadius = 8
        tripImageView.clipsToBounds = true
        guard let trip = trip,
            let photoAsData = trip.photo
            else { return }
        let photo = UIImage(data: photoAsData)
        tripImageView.image = photo
        tripNameLabel.text = trip.location
        
    }

    
}
