//
//  FMButton.swift
//  MyTravels
//
//  Created by Frank Martin on 3/17/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class FMButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.3490196078, blue: 0.3490196078, alpha: 1)
//        let attributedString = NSAttributedString(string: self.titleLabel?.text ?? "blah", attributes: [NSAttributedString.Key.font : UIFont(name: "Poppins-SemiBold", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.white,
//            NSAttributedString.Key.strokeColor : UIColor.white])
//        self.setAttributedTitle(attributedString, for: .normal)
        self.layer.cornerRadius = 7
        self.clipsToBounds = true
    }
}
