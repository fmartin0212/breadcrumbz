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
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
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
        placeAddressLabel.text = place.address
        
    }
    
    func updateStarsImageViews() {
        let starImageViewsArray = [starOne, starTwo, starThree, starFour, starFive]
        guard let place = place else { return }
        if place.rating == 0 {
            for starImageView in starImageViewsArray {
                starImageView?.image = UIImage(named: )
            }
        }
    }
}
