//
//  MapViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/3/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let geocoder = CLGeocoder()
        let testAddress = "16679 Rocky Creek Dr. Riverside, CA"
        geocoder.geocodeAddressString(testAddress) { (placemark, error) in
            guard let placemark = placemark else { return }
            let location = placemark.first?.location
            
            
            print(location?.coordinate)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        
        
        
        return annotationView
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
