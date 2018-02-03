//
//  ViewControllerExtensions.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/3/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func sectionHeaderLabelWith(text: String) -> UILabel {
        let headerLabel = UILabel()
        headerLabel.font = UIFont(name: "AvenirNext-Bold", size: 25)
        headerLabel.text = text
        return headerLabel
    }
    
}
