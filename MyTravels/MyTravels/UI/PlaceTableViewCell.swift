//
//  PlaceTableViewCell.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/3/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var place: Place? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    // MARK: - Functions
    func updateViews() {
        
        // Round edges on imageviews
        placeImageView.layer.cornerRadius = 5
        placeImageView.clipsToBounds = true
        
        guard let place = place,
            let photoAsData = place.photo
            else { return }
        let photo = UIImage(data: photoAsData)
        placeImageView.image = photo
        placeNameLabel.text = place.name
        
    }
}
