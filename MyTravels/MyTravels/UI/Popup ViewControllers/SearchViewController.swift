//
//  SearchViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/11/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol SearchViewControllerDelegate: class {
    func set(address: String)
}

class SearchViewController: UIViewController {
    
    // MARK: - Constants & Variables
    
    // MapKit
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    // CoreLocation
    var locationManager = CLLocationManager()
    var usersCurrentLocationAsAddressString: String = ""
    
    weak var delegate: SearchViewControllerDelegate?
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indicatorVisualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        searchCompleter.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
}

extension SearchViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Need to eventually protect against potential changes, see Apple docs
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        view.isUserInteractionEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let location = locations.first else { return }
        print(location)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Could not reverse geocode location. Error: \(error)")
            }
            guard let placemarks = placemarks,
                let placemark = placemarks.first
                else { return }
            guard let name = placemark.name,
                let postalCode = placemark.postalCode,
                let locality = placemark.locality,
                let administrativeArea = placemark.administrativeArea,
                let country = placemark.country
                else { return }
            //                    self.geoCodeAlert()
            self.usersCurrentLocationAsAddressString = "\(name), \(locality), \(administrativeArea) \(postalCode), \(country)"
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.view.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.2, animations: {
                self.indicatorVisualEffectView.alpha = 0
            })
        }
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
    func highlightedText(_ text: String, inRanges ranges: [NSValue], size: CGFloat) -> NSAttributedString {
        
        let attributedText = NSMutableAttributedString(string: text)
        let regular = UIFont.systemFont(ofSize: size)
        attributedText.addAttribute(NSAttributedStringKey.font, value:regular, range:NSMakeRange(0, text.count))
        
        let bold = UIFont.boldSystemFont(ofSize: size)
        for value in ranges {
            attributedText.addAttribute(NSAttributedStringKey.font, value:bold, range:value.rangeValue)
        }
        return attributedText
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = "My Location"
            return cell
        }
            
        else {
            let searchResult = searchResults[indexPath.row - 1]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.attributedText = highlightedText(searchResult.title, inRanges: searchResult.titleHighlightRanges, size: 17.0)
            cell.detailTextLabel?.attributedText = highlightedText(searchResult.subtitle, inRanges: searchResult.subtitleHighlightRanges, size: 12.0)
            return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            delegate?.set(address: self.usersCurrentLocationAsAddressString)
            dismiss(animated: true, completion: nil)
        }
            
        else {
            let completion = searchResults[indexPath.row - 1]
            
            let searchRequest = MKLocalSearchRequest(completion: completion)
            let search = MKLocalSearch(request: searchRequest)
            search.start { (response, error) in
                
                guard let response = response else { return }
                
                let coordinate = response.mapItems[0].placemark.coordinate
                let latitude = coordinate.latitude
                let longitude = coordinate.longitude
                let location = CLLocation(latitude: latitude, longitude: longitude)
                
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    if let error = error {
                        print("Could not reverse geocode location. Error: \(error)")
                    }
                    guard let placemarks = placemarks,
                        let placemark = placemarks.first,
                        let name = placemark.name,
                        let postalCode = placemark.postalCode,
                        let locality = placemark.locality,
                        let administrativeArea = placemark.administrativeArea,
                        let country = placemark.country
                        else { return }
                    //                    self.geoCodeAlert()
                    let selectedAddress = "\(name), \(locality), \(administrativeArea) \(postalCode), \(country)"
                    self.delegate?.set(address: selectedAddress)
                    //            self.delegate?.updateLongLat(long: longitude, lat: latitude)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

