//
//  FMTextField.swift
//  MyTravels
//
//  Created by Frank Martin on 2/27/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class FMTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 2
        self.borderStyle = .none
       
        // Border
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.3
        
        // Shadow
//        self.layer.shadowColor = UIColor.lightGray.cgColor
//        self.layer.shadowRadius = 1.7
//        self.layer.shadowOpacity = 0.2
//        self.layer.shadowOffset = CGSize(width: 0, height: 3)
//        self.layer.masksToBounds = false
//        self.layer.backgroundColor = UIColor.white.cgColor
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputAccessoryView = toolbar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
