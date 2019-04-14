//
//  SharedPlaceDetailTableViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import MapKit

class SharedPlaceDetailTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var sharedTrip: SharedTrip?
    var sharedPlace: SharedPlace?
    
    var photos: [Photo] = []
    var placemark: CLPlacemark?
    // MARK: - IBOutlets
    
    @IBOutlet weak var sharedPlaceMainPhotoImageView: UIImageView!
    @IBOutlet weak var sharedPlaceNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
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
        
        // Set collectionview datasource/delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Set MapView properties
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        
        // Update the views for the shared place.
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
        
        addAnnotation(for: sharedPlace)
        
        if sharedPlace.photos.count > 0 {
            guard let mainPhoto = sharedPlace.photos.first else { return }
            sharedPlaceMainPhotoImageView.image = mainPhoto
            sharedPlaceNameLabel.text = sharedPlace.name.uppercased()
            sharedPlaceAddressLabel.text = sharedPlace.address
            updateStarsImageViews(sharedPlace: sharedPlace)
            
        } else {
            var placeholderImage = UIImage()
//            if sharedPlace.type == "Lodging" {
//                guard let lodgingPlaceholderImage = UIImage(named: "Lodging") else { return }
//                placeholderImage = lodgingPlaceholderImage
//            } else if sharedPlace.type == "Restaurant" {
//                guard let restaurantPlaceholderImage = UIImage(named: "Restaurant") else { return }
//                placeholderImage = restaurantPlaceholderImage
//            } else if sharedPlace.type == "Activity" {
//                guard let activityPlaceholderImage = UIImage(named: "Activity") else { return }
//                placeholderImage = activityPlaceholderImage
//            }
            
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

        let ratingAsFloat = Float(sharedPlace.rating)
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
    
    func addAnnotation(for sharedPlace: SharedPlace) {
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(sharedPlace.address) { (placemarks, error) in
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
}

// MARK: - Table View Delegate

extension SharedPlaceDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            
            guard let placemark = placemark,
                let location = placemark.location
            else { return }
            
            let region = MKCoordinateRegion.init(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
            
            let options = [
                MKLaunchOptionsCameraKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
            ]
            let mkPlacemark = MKPlacemark(placemark: placemark)
            let mapItem = MKMapItem(placemark: mkPlacemark)
            
            mapItem.openInMaps(launchOptions: options)
            
        }
    }
}

extension SharedPlaceDetailTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sharedPlace = sharedPlace
            else { return 0 }
        
        return sharedPlace.photos.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        
        guard let sharedPlace = sharedPlace
            else { return UICollectionViewCell() }
        
        cell.sharedPlacePhoto = sharedPlace.photos[indexPath.row]
        
        return cell
    }
}

extension SharedPlaceDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

