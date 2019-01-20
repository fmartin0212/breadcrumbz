//
//  PlaceDetailTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/3/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import MapKit

class PlaceDetailTableViewController: UITableViewController {

    // MARK: Properties
    
    var trip: Trip?
    var place: Place?
    var photos: [Photo] = []
    var placemark: CLPlacemark?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var placeMainPhotoImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeCommentsTextView: UITextView!
    
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set the title to the user-owned place's name
        if let _ = place {
            updateViews()
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        updateViews()
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
        
        if place.comments == "Comments" {
            placeCommentsTextView.text = ""
        } else {
            placeCommentsTextView.text = place.comments
        }
        
        addAnnotation(for: place)
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
    
    
    func addAnnotation(for place: Place) {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(place.address) { (placemarks, error) in
            if let error = error {
                print("There was an error finding a placemark : \(error.localizedDescription)")
                return
            }
            guard let placemarks = placemarks,
                let placemark = placemarks.first,
                let coordinate = placemark.location?.coordinate
                else { return }
            
            self.placemark = placemark
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            self.mapView.setRegion(region, animated: false)
            self.mapView.addAnnotation(annotation)
            
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

            guard let photo = photos[indexPath.row].photo
                else { return UICollectionViewCell() }
            
            cell.photo = photo as Data
            
            return cell
        }
}

extension PlaceDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
