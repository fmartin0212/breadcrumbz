//
//  Extensions.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 6/5/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    func format() {
        let attributes = [
            NSAttributedStringKey.font : UIFont(name: "AvenirNext-Regular", size: 17) as Any
        ]
        
        self.setTitleTextAttributes(attributes, for: .normal)
        self.setTitleTextAttributes(attributes, for: .selected)
    }
}

extension UIButton {
  
    func formatBlue() {
         self.layer.cornerRadius = 8
    }
}

extension UIViewController {
  
    func presentTripListVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tripListNavigationController = storyboard.instantiateViewController(withIdentifier: "TabBarController")
        self.present(tripListNavigationController, animated: true, completion: nil)
    }
}

extension Date {
    
    func short() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: self)
        
        return date
    }
}

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { rendererContext in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension UITextField {
    
    func addKeyboardDone(targetVC: UIViewController, selector: Selector ) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: targetVC, action: selector)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.inputAccessoryView = toolbar
        
    }
//    Causes invalid instance sent to selector crash
//    @objc func dismissKeyboard(targetVC: UIViewController) {
//        targetVC.view.endEditing(true)
//    }
}
