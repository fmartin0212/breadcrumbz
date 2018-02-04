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
        updateStarsImageViews(place: place)
        
    }
    
    func updateStarsImageViews(place: Place) {
        
        let starImageViewsArray = [starOne, starTwo, starThree, starFour, starFive]
        
        if place.rating == 0 {
            for starImageView in starImageViewsArray {
                starImageView?.image = UIImage(named: "star-clear-16")
            }
        } else if place.rating > 0 {
            var i = 0
            while i < Int(place.rating) {
                starImageViewsArray[i]?.image = UIImage(named: "star-black-16")
                i += 1
            }
        
            while i <= starImageViewsArray.count - 1 {
                starImageViewsArray[i]?.image = UIImage(named: "star-clear-16")
                i += 1
            }
            
        }
    }
    
}
