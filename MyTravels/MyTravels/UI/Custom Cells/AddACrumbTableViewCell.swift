//
//  AddACrumbTableViewCell.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/20/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class AddACrumbTableViewCell: UITableViewCell {

    @IBOutlet weak var crumbLabel: UILabel!
    
    var tripHasCrumbs: Bool? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let tripHasCrumbs = tripHasCrumbs else { return }
        tripHasCrumbs ? (crumbLabel.text = "Add a crumb") : (crumbLabel.text = "You don't have any crumbz. Tap here to get started!")
    }
}
