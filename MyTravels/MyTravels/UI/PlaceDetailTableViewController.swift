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
    var trip: Trip?
    var place: Place? {
        didSet {
            guard let place = place else { return }
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
//        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
//         self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        self.title = place?.name
        
        guard let photos = place?.photos?.allObjects as? [Photo]
            else { return }
        self.photos = photos
            
        updateViews()
    }
    
    // MARK: - Functions
    func updateViews() {
        guard let place = place,
            let photos = place.photos?.allObjects as? [Photo],
            let photo = photos[0].photo
            else { return }
        
        if photos.count > 0 {
        placeMainPhotoImageView.image = UIImage(data: photo)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        guard let photo = photos[indexPath.row].photo else { return UICollectionViewCell() }

        cell.photo = photo
        
        return cell
        
    }
    
}
