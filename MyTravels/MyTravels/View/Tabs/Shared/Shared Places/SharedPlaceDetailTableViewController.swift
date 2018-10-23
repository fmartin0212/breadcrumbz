//
//  SharedPlaceDetailTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedPlaceDetailTableViewController: UITableViewController {
    
    // MARK: Properties
    var sharedTrip: SharedTrip?
    var sharedPlace: SharedPlace?
    
    var photos: [Photo] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var sharedPlaceMainPhotoImageView: UIImageView!
    @IBOutlet weak var sharedPlaceNameLabel: UILabel!
    @IBOutlet weak var sharedPlaceAddressLabel: UILabel!
    @IBOutlet var sharedPlaceCommentsTextView: UITextView!
    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        
        updateViewsForSharedPlace()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewsForSharedPlace()
        collectionView.reloadData()
    }
    
    // MARK: - Functions
    
    func updateViewsForSharedPlace() {
        guard let sharedPlace = sharedPlace
            else { return }
        
        if let photos = sharedPlace.photos, photos.count > 0 {
            guard let photo = photos.first else { return }
            sharedPlaceMainPhotoImageView.image = photo
            sharedPlaceNameLabel.text = sharedPlace.name
            sharedPlaceAddressLabel.text = sharedPlace.address
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
            
            sharedPlaceMainPhotoImageView.image = placeholderImage
            sharedPlaceNameLabel.text = sharedPlace.name
            sharedPlaceAddressLabel.text = sharedPlace.address
            updateStarsImageViews(sharedPlace: sharedPlace)
        }
        
        if sharedPlace.comments == "Comments" {
            sharedPlaceCommentsTextView.text = ""
        } else {
            sharedPlaceCommentsTextView.text = sharedPlace.comments
        }
    }
    
    func updateStarsImageViews(sharedPlace: SharedPlace) {
        guard let ratingAsInt16 = sharedPlace.rating else { return }
        let ratingAsFloat = Float(ratingAsInt16)
        let rating = Int(ratingAsFloat)
        let stars: [UIImageView] = [starOne, starTwo, starThree, starFour, starFive]
        
        if rating == 5 {
            for star in stars {
                star.image = UIImage(named: "star-black-16")
            }
            return
        }
        
        for star in 0...(rating - 1) {
            stars[star].image = UIImage(named: "star-black-16")
        }
        
        for star in rating...4 {
            stars[star].image = UIImage(named: "star-clear-16")
        }
    }
}

extension SharedPlaceDetailTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sharedPlace = sharedPlace,
            let sharedPlacePhotos = sharedPlace.photos
            else { return 0 }
        
        return sharedPlacePhotos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        guard let sharedPlace = sharedPlace,
            let sharedPlacePhotos = sharedPlace.photos
            else { return UICollectionViewCell() }
        
        cell.sharedPlacePhoto = sharedPlacePhotos[indexPath.row]
        
        return cell
    }
}

extension SharedPlaceDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

