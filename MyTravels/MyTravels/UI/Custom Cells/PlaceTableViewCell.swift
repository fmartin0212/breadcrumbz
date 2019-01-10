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
    var sharedPlace: SharedPlace? {
        didSet {
            updateViewsForSharedPlace()
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
            let photosAsSet = place.photos,
            let photosArray = photosAsSet.allObjects as? [Photo]
            
            else { return }
        if photosArray.count > 0 {
            guard let photo = photosArray[0].photo as Data?,
                let image = UIImage(data: photo) else { return }
            placeImageView.image = image
            placeNameLabel.text = place.name
            placeAddressLabel.text = place.address
            updateStarsImageViews(place: place)
        } else {
            var placeholderImage = UIImage()
            if place.type == "Lodging" {
                guard let lodgingPlaceholderImage = UIImage(named: "Lodging") else { return }
                placeholderImage = lodgingPlaceholderImage
            } else if place.type == "Restaurant" {
                guard let restaurantPlaceholderImage = UIImage(named: "Restaurant") else { return }
                placeholderImage = restaurantPlaceholderImage
            } else if place.type == "Activity" {
                guard let activityPlaceholderImage = UIImage(named: "Activity") else { return }
                placeholderImage = activityPlaceholderImage
            }
            
            placeImageView.image = placeholderImage
            placeNameLabel.text = place.name
            placeAddressLabel.text = place.address
            placeAddressLabel.adjustsFontSizeToFitWidth = true
            updateStarsImageViews(place: place)
            
        }
        
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
    
    func updateViewsForSharedPlace() {
        
        // Round edges on imageviews
        placeImageView.layer.cornerRadius = 5
        placeImageView.clipsToBounds = true
        
        guard let sharedPlace = sharedPlace
            else { return }
        
        if sharedPlace.photos.count > 0 {
            let mainPhoto = sharedPlace.photos[0]
            placeImageView.image = mainPhoto
            placeNameLabel.text = sharedPlace.name
            placeAddressLabel.text = sharedPlace.address
            updateStarsImageViews(sharedPlace: sharedPlace)

        } else {
            var placeholderImage = UIImage()
            if sharedPlace.type == "Lodging" {
                guard let lodgingPlaceholderImage = UIImage(named: "Lodging") else { return }
                placeholderImage = lodgingPlaceholderImage
            } else if sharedPlace.type == "Restaurant" {
                guard let restaurantPlaceholderImage = UIImage(named: "Restaurant") else { return }
                placeholderImage = restaurantPlaceholderImage
            } else if sharedPlace.type == "Activity" {
                guard let activityPlaceholderImage = UIImage(named: "Activity") else { return }
                placeholderImage = activityPlaceholderImage
            }
            
            placeImageView.image = placeholderImage
            placeNameLabel.text = sharedPlace.name
            placeAddressLabel.text = sharedPlace.address
            updateStarsImageViews(sharedPlace: sharedPlace)
        }
        
    }
    
    func updateStarsImageViews(sharedPlace: SharedPlace) {
        
        let starImageViewsArray = [starOne, starTwo, starThree, starFour, starFive]
        if sharedPlace.rating == 0 {
            for starImageView in starImageViewsArray {
                starImageView?.image = UIImage(named: "star-clear-16")
            }
        } else if sharedPlace.rating > 0 {
            var i = 0
            while i < sharedPlace.rating {
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


