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
    
    var trip: Trip? {
        didSet {
            updateViews(trip: trip)
        }
    }
    
    var sharedTrip: SharedTrip? {
        didSet {
            updateViews(sharedTrip: sharedTrip)
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripCreatorLabel: UILabel!
    
    }

extension TripTableViewCell {
    
    func updateViews(trip: Trip? = nil, sharedTrip: SharedTrip? = nil) {
        
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        var tripPhoto = UIImage()
        
        if let trip = trip {
            
            tripCreatorLabel.isHidden = true
            if let photo = trip.photo?.photo as Data? {
                guard let image = UIImage(data: photo) else { return }
                tripPhoto = image
            } else {
                guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
                tripPhoto = tripPhotoPlaceholderImage
            }
            
            tripNameLabel.text = trip.name
            tripImageView.image = tripPhoto
            tripLocationLabel.text = trip.location
            
            tripStartDateLabel.text = (trip.startDate as Date).short() + " - "
            tripEndDateLabel.text = (trip.endDate as Date).short()
            
        } else if let sharedTrip = sharedTrip {
            if let photo = sharedTrip.photo {
                tripPhoto = photo
            } else {
                guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
                tripPhoto = tripPhotoPlaceholderImage
            }
            
            tripNameLabel.text = sharedTrip.name
            tripImageView.image = tripPhoto
            tripLocationLabel.text = sharedTrip.location
            tripStartDateLabel.text = (sharedTrip.startDate as Date).short() + " - "
            tripEndDateLabel.text = (sharedTrip.endDate as Date).short()
            tripCreatorLabel.text = sharedTrip.creatorName
            
        }
    }
}
