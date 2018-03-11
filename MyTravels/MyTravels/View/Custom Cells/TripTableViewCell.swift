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
    
    var localTrip: SharedTrip? {
        didSet {
            updateViewsLocalTrip()
        }
    }
    
    // MARK: - IBOutlets
    // Trip
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDatesLabel: UILabel!
    @IBOutlet weak var tripStartDateLabel: UILabel!
    @IBOutlet weak var tripEndDateLabel: UILabel!
    
    // MARK: - Functions
    func updateViews() {
        
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        
        guard let trip = trip,
            let startDate = trip.startDate,
            let endDate = trip.endDate
            else { return }
        
        var tripPhoto = UIImage()
        guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
        tripPhoto = tripPhotoPlaceholderImage
        if let photo = trip.photo?.photo as Data? {
            guard let image = UIImage(data: photo) else { return }
            tripPhoto = image
        }
        
        tripImageView.image = tripPhoto
        tripNameLabel.text = trip.location
        
        tripStartDateLabel.text = "\(shortDateString(date: startDate as Date)) -"
        tripEndDateLabel.text = shortDateString(date: endDate as Date)
    
    }
    
    func updateViewsLocalTrip() {
        
        tripImageView.layer.cornerRadius = 4
        tripImageView.clipsToBounds = true
        
        guard let localTrip = localTrip else { return }
        
        var tripPhoto = UIImage()
        guard let tripPhotoPlaceholderImage = UIImage(named: "map") else { return }
        tripPhoto = tripPhotoPlaceholderImage
        
        if let photoData = localTrip.photoData {
            guard let photo = UIImage(data: photoData) else { return }
            tripPhoto = photo
        }
        
        tripImageView.image = tripPhoto
        tripNameLabel.text = localTrip.location
        
        tripStartDateLabel.text = "\(shortDateString(date: localTrip.startDate as Date)) -"
        tripEndDateLabel.text = shortDateString(date: localTrip.endDate as Date)
    }
    
    func shortDateString(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: date)
        
        return date
        
    }

}
