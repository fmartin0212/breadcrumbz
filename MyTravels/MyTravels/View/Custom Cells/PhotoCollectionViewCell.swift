//
//  PhotoCollectionViewCell.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/5/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var photo: Data? {
        didSet {
            
            guard let photoAsData = photo else { return }
            let photoImage = UIImage(data: photoAsData)
            
            photoImageView.image = photoImage
            photoImageView.layer.cornerRadius = 8
            photoImageView.clipsToBounds = true
        }
    }
    
    var sharedPlacePhoto: Data? {
        didSet {
            
            guard let photoAsData = sharedPlacePhoto else { return }
            let photoImage = UIImage(data: photoAsData)
            
            photoImageView.image = photoImage
            photoImageView.layer.cornerRadius = 8
            photoImageView.clipsToBounds = true
        }
    }

    
    // MARK: - IBOutlets
    // Create new place
    @IBOutlet weak var photoImageView: UIImageView!
}
