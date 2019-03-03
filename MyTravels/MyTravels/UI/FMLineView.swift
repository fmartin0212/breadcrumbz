//
//  FMLineView.swift
//  MyTravels
//
//  Created by Frank Martin on 3/2/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class FMLineView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.1
        self.layer.shadowRadius = 0.8
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}