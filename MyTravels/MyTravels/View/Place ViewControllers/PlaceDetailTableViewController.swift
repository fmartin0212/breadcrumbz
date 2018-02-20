//
//  PlaceDetailTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/3/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class PlaceDetailTableViewController: UITableViewController {

    // MARK: Properties
    var sharedPlaceView: Bool?
    var trip: Trip?
    var place: Place? {
        didSet {
            sharedPlaceView = false
        }
    }
    
    var sharedTrip: LocalTrip? 
    
    var sharedPlace: LocalPlace? {
        didSet {
            sharedPlaceView = true
        }
    }
    
    var photos: [Photo] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var placeMainPhotoImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
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
        
        // Set the title to the user-owned place's name
        if let place = place {
            self.title = place.name
            updateViews()
        }
        
        if let sharedPlace = sharedPlace {
            self.title = sharedPlace.name
            updateViewsForSharedPlace()
            
        }
        
        
        tableView.contentOffset = CGPoint(x: 30, y: 30)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
        collectionView.reloadData()
    }
    
    // MARK: - Functions
    func updateViews() {
        guard let place = place,
            let photos = place.photos?.allObjects as? [Photo]
            else { return }
        
        self.photos = photos
        
        if photos.count > 0 {
            guard let photo = photos[0].photo as Data?,
                let image = UIImage(data: photo) else { return }
            placeMainPhotoImageView.image = image
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
            placeMainPhotoImageView.image = placeholderImage
            placeNameLabel.text = place.name
            placeAddressLabel.text = place.address
            updateStarsImageViews(place: place)
        }
    }
    
    func updateViewsForSharedPlace() {
        guard let sharedPlace = sharedPlace,
            let photos = sharedPlace.photos
            else { return }
            
            if photos.count > 0 {
                guard let photo = photos.first,
                    let image = UIImage(data: photo) else { return }
                placeMainPhotoImageView.image = image
                placeNameLabel.text = sharedPlace.name
                placeAddressLabel.text = sharedPlace.address
//                updateStarsImageViews(place: place)
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
                placeMainPhotoImageView.image = placeholderImage
                placeNameLabel.text = sharedPlace.name
                placeAddressLabel.text = sharedPlace.address
//                updateStarsImageViews(place: place)
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
    
    func updateStarsImageViews(sharedPlace: LocalPlace) {
        guard let sharedPlaceRating = sharedPlace.rating else { return }
        let starImageViewsArray = [starOne, starTwo, starThree, starFour, starFive]
        
        if sharedPlace.rating == 0 {
            for starImageView in starImageViewsArray {
                starImageView?.image = UIImage(named: "star-clear-16")
            }
        } else if Int(sharedPlaceRating) > 0 {
            var i = 0
            
            while i < Int(sharedPlaceRating) {
                starImageViewsArray[i]?.image = UIImage(named: "star-black-16")
                i += 1
            }
            
            while i <= starImageViewsArray.count - 1 {
                starImageViewsArray[i]?.image = UIImage(named: "star-clear-16")
                i += 1
            }
        }
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEditPlaceTableViewControllerSegue" {
            guard let destinationVC = segue.destination as? EditPlaceTableViewController,
            let place = place
                else { return }
            destinationVC.trip = trip
            destinationVC.place = place
        }
    }

}

extension PlaceDetailTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int 
    {
        if sharedPlaceView == false {
            
            return photos.count
        }
        
        guard let sharedPlace = sharedPlace,
        let sharedPlacePhotos = sharedPlace.photos
        else { return 0 }
        
        return sharedPlacePhotos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if sharedPlaceView == false {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
            print (photos.count)
            guard let photo = photos[indexPath.row].photo
                else { return UICollectionViewCell() }
            
            cell.photo = photo as? Data
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        guard let sharedPlace = sharedPlace,
            let sharedPlacePhotos = sharedPlace.photos
            else { return UICollectionViewCell() }
        
            cell.sharedPlacePhoto = sharedPlacePhotos[indexPath.row]
        
        return cell
    }
    
}
