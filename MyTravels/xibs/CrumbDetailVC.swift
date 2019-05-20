//
//  CrumbDetailVC.swift
//  MyTravels
//
//  Created by Frank Martin on 3/16/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit
import MapKit

class CrumbDetailVC: UIViewController {
    
    // MARK: - Properties
    
    var crumb: CrumbObject?
    
    var photos: [UIImage] = []
    var cellIndex: Int = 0
    var willDisplayCellIndex = 0
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    init(crumb: CrumbObject, nibName: String) {
        self.crumb = crumb
        super.init(nibName: nibName, bundle: nil)
    }
  
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        formatViews()
        updateViews()
    }
    
    func formatViews() {
        mapView.layer.cornerRadius = 8
        mapView.clipsToBounds = true
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
    }
    
    func updateViews() {
        guard let crumb = crumb else { return }
        fetchPhotos(for: crumb)
        name.text = crumb.name
        address.text = crumb.address
        comments.text = crumb.comments
        type.text = crumb.type?.rawValue
        addAnnotation(for: crumb)
    }
    
    func fetchPhotos(for crumb: CrumbObject) {
        PhotoController.shared.fetchPhotos(for: crumb) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let photos):
                self?.photos = photos
                DispatchQueue.main.async {
                    self?.pageControl.numberOfPages = photos.count
                    self?.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    func addAnnotation(for place: CrumbObject) {
        
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
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            
            self.mapView.setRegion(region, animated: false)
            self.mapView.addAnnotation(annotation)
        }
    }
}

extension CrumbDetailVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        guard photos.count > 0 else { return UICollectionViewCell() }
        let photo = photos[indexPath.row]
        let photoImageView = UIImageView(image: photo)
        photoImageView.contentMode = .scaleAspectFill
        cell.backgroundView = photoImageView
        return cell
    }
}

extension CrumbDetailVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: imageCollectionView.frame.width, height: imageCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension CrumbDetailVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if willDisplayCellIndex == cellIndex {
            cellIndex = indexPath.row
            return
        }
      
        var newIndex = cellIndex
        print(cellIndex)
        cellIndex < indexPath.row ? (newIndex -= 1) : (newIndex += 1)
        print(newIndex)
        pageControl.currentPage = newIndex
        cellIndex = newIndex
        print("willEndDisplay: \(indexPath.row)")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplayCellIndex = indexPath.row
        print("willDisplay: \(indexPath.row)")
    }
}
