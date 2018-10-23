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
    
    var sharedTrip: SharedTrip? {
        didSet {
            updateViewsForSharedTrip()
        }
    }
    
    var user: InternalUser? {
        didSet {
            updateViewsForUser()
        }
    }
    
    var indexPath: IndexPath?
    
    // MARK: - IBOutlets
    // Trip
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripLocationLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    @IBOutlet weak var tripCreatorLabel: UILabel!
    
    // MARK: - Functions
    func updateViews() {
        
        guard let trip = trip
            else { return }
        
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        
        
        var tripPhoto = UIImage()
        guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
        tripPhoto = tripPhotoPlaceholderImage
        if let photo = trip.photo?.photo as Data? {
            guard let image = UIImage(data: photo) else { return }
            tripPhoto = image
        }
        
        tripNameLabel.text = trip.name
        tripImageView.image = tripPhoto
        tripLocationLabel.text = trip.location
        
        tripStartDateLabel.text = "\(shortDateString(date: trip.startDate as Date)) -"
        tripEndDateLabel.text = shortDateString(date: trip.endDate as Date)
        
    }
    
    func updateViewsForSharedTrip() {
        
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        
        guard let sharedTrip = sharedTrip else { return }
        
        var tripPhoto = UIImage()
        guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
        tripPhoto = tripPhotoPlaceholderImage
        
        if let photo = sharedTrip.photo {
            tripPhoto = photo
        }
        
        tripNameLabel.text = sharedTrip.name
        tripImageView.image = tripPhoto
        tripLocationLabel.text = sharedTrip.location
        
        tripStartDateLabel.text = "\(shortDateString(date: sharedTrip.startDate as Date)) -"
        tripEndDateLabel.text = "\(shortDateString(date: sharedTrip.endDate as Date))"
        tripCreatorLabel.text = sharedTrip.creatorName

    }
    
    func updateViewsForUser() {
        guard let user = user else { return }
        DispatchQueue.main.async {
            self.tripCreatorLabel.alpha = 1
            self.tripCreatorLabel.text = user.firstName
        }
    }
    
    func shortDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: date)
        
        return date
        
    }
}
