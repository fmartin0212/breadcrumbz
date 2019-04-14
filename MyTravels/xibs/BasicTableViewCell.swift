//
//  BasicTableViewCell.swift
//  MyTravels
//
//  Created by Frank Martin on 3/17/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

protocol BasicTableViewCellDelegate: class {
    func switchToggled()
}

class BasicTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: BasicTableViewCellDelegate?
    
    // Outlets
    @IBOutlet weak var basicLabel: UILabel!
    @IBOutlet weak var basicSwitch: UISwitch!

    // MARK: - Actions
    
    @IBAction func switchToggled(_ sender: Any) {
        delegate?.switchToggled()
    }
}
