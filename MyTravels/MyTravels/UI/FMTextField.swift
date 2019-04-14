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
        
        self.layer.cornerRadius = 4
        self.borderStyle = .none
       
        // Border
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.3
        
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
