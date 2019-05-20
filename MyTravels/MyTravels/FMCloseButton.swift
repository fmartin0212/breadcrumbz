//
//  FMCloseButton.swift
//  MyTravels
//
//  Created by Frank Martin on 5/19/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class FMCloseButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
        self.titleLabel?.textColor = .white
        self.setTitle("X", for: .normal)
        let attrStr = NSAttributedString(string: "X", attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-Light", size: 10) as Any, NSAttributedString.Key.foregroundColor : UIColor.white])
        self.layer.cornerRadius = self.frame.width / 2
        
        self.setAttributedTitle(attrStr, for: .normal)
    }
}
