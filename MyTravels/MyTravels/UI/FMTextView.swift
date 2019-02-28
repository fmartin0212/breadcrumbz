//
//  FMTextView.swift
//  MyTravels
//
//  Created by Frank Martin on 2/27/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class FMTextView: UITextView {

    init() {
        super.init(frame: .zero, textContainer: NSTextContainer())
        
        self.layer.cornerRadius = 2
        
        // Border
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.3
        
        // Shadow
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 1.7
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.masksToBounds = false
        self.layer.backgroundColor = UIColor.white.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
