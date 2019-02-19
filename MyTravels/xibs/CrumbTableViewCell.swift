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
    @IBOutlet weak var numberBackdropView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var accessoryLabel: UILabel!
    
    var number: Int?
    var crumb: Place? {
        didSet {
            updateViews()
        }
    }
}

//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    

extension CrumbTableViewCell {
    
    func updateViews() {
        guard let crumb = crumb,
            let number = number
            else { return }
        numberBackdropView.layer.cornerRadius = numberBackdropView.frame.height / 2
        numberLabel.text = String(number)
        nameLabel.text = crumb.name
        typeLabel.text = crumb.type?.rawValue
    }
}
