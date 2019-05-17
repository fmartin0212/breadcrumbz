//
//  CrumbTableViewCell.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/18/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class CrumbTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var crumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var accessoryLabel: UILabel!
    
    var crumb: CrumbObject? {
        didSet {
            updateViews()
        }
    }
}

extension CrumbTableViewCell {
    
    func updateViews() {
        guard let crumb = crumb else { return }
        crumbImageView.clipsToBounds = true
        crumbImageView.layer.cornerRadius = 8
        nameLabel.text = crumb.name
        commentsLabel.text = crumb.comments
    }
}
