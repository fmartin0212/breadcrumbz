//
//  TripPlaceTableViewCell
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripPlaceTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var trip: Trip? {
        didSet {
            updateViewsForTrip()
        }
    }
    var place: Place? {
        didSet {
            updateViewForPlace()
        }
    }
    
    // MARK: - IBOutlets
    // Trip
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripRecommendationImageView: UIImageView!
    
    // Place
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var recommendationImageView: UIImageView!
    
    override func awakeFromNib() {
        
     
    }
    
    // MARK: - Functions
    func updateViewsForTrip() {
        tripRecommendationImageView.isHidden = true
        tripImageView.layer.cornerRadius = 8
        tripImageView.clipsToBounds = true
        guard let trip = trip,
            let photoAsData = trip.photo
            else { return }
        let photo = UIImage(data: photoAsData)
        tripImageView.image = photo
        tripNameLabel.text = trip.location
        
    }
    
    func updateViewForPlace() {
        placeImageView.layer.cornerRadius = 8
        placeImageView.clipsToBounds = true
        
        guard let place = place,
            let photoAsData = place.photo
            else { return }
        let photo = UIImage(data: photoAsData)
        placeImageView.image = photo
        placeNameLabel.text = place.name
        recommendationImageView.image = UIImage(named: "thumb-up")
    }
    
}
