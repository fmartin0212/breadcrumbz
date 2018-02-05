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
    
    func setPropertiesFor(overlayView: UIView) {
      
        overlayView.layer.shadowColor = UIColor.black.cgColor
        overlayView.layer.shadowOpacity = 0.5
        overlayView.layer.shadowOffset = CGSize.zero
        overlayView.layer.shadowRadius = 5
        overlayView.layer.cornerRadius = 8
        
    }
    
    func setPropertiesFor(button: UIButton) {
       
        button.backgroundColor = #colorLiteral(red: 1, green: 0.7723504523, blue: 0.6153716984, alpha: 1)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 8
        
    }

}
