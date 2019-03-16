//
//  ImageCollectionViewCell.swift
//  MyTravels
//
//  Created by Frank Martin on 3/16/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

protocol ImageCollectionViewCellDelegate: class {
    
    func addPhotoButtonTapped(cell: ImageCollectionViewCell)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    var delegate: ImageCollectionViewCellDelegate?
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    @IBAction func addPhotoButton(_ sender: Any) {
        delegate?.addPhotoButtonTapped(cell: self)
    }
}
