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
    var place: Place? {
        didSet {
            guard let place = place else { return }
//            placeNameLabel.text = place.name
//            placeAddressLabel.text = place.address
//            tableView.reloadData()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var placeMainPhotoImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var starOne: UIImageView!
    @IBOutlet weak var starTwo: UIImageView!
    @IBOutlet weak var starThree: UIImageView!
    @IBOutlet weak var starFour: UIImageView!
    @IBOutlet weak var starFive: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
//         self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        updateViews()
    }
    
    // MARK: - Functions
    func updateViews() {
        guard let place = place,
        let photo = place.photo
        else { return }
        placeMainPhotoImageView.image = UIImage(data: photo)
        placeNameLabel.text = place.name
        placeAddressLabel.text = place.address
    }

    // MARK: - Table view data source
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        guard let place = place,
//        let photo = place.photo
//            else { return UIView() }
//        if section == 0 {
//            let image = UIImage(data: photo)
//            let imageView = UIImageView(image: image)
//
//            return imageView
//        }
//        return UIView()
//    }

}
