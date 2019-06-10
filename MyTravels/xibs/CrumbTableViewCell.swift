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
    @IBOutlet weak var typeImageBackgroundView: UIView!
    var crumb: CrumbObject? {
        didSet {
            updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        formatViews()
    }
}

extension CrumbTableViewCell {
    
    private func updateViews() {
        guard let crumb = crumb else { return }
        nameLabel.text = crumb.name
        commentsLabel.text = crumb.comments
    }
    
    private func formatViews() {
        DispatchQueue.main.async { [weak self] in
            guard let bgWidth = self?.typeImageBackgroundView.frame.width else { return }
            self?.typeImageBackgroundView.layer.cornerRadius = bgWidth / 2
            self?.typeImageBackgroundView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self?.typeImageBackgroundView.layer.borderWidth = 1.1
        }
    }
}
