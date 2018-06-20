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
        headerLabel.font = UIFont(name: "AvenirNext-Medium", size: 25)
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
       
        button.backgroundColor = UIColor(red: 255, green: 77, blue: 77, alpha: 1.0)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 8
        
    }
    
    func missingFieldAlert(textFields: [UITextField]) {
       
        var textFieldNamesArray: [String] = []
        for textField in textFields {
            if textField.placeholder == "Name" && textField.text?.isEmpty == true {
                textFieldNamesArray.append("Name")
            }
                
            if textField.text == "Choose a start date" {
                textFieldNamesArray.append("Start Date")
            }
            
            if textField.text == "Choose an end date" {
                textFieldNamesArray.append("End Date")
            }
                
            else if textField.placeholder == "Address" && textField.text?.isEmpty == true {
                textFieldNamesArray.append("Address")
            }
            else if textField.text == "Choose a type" {
                textFieldNamesArray.append("Type")
            }
        }
        
        var missingFields = ""
        for textFieldName in textFieldNamesArray {
            if textFieldNamesArray.count == 1 {
                missingFields += textFieldName
            } else if textFieldNamesArray.count == 2 && textFieldName == textFieldNamesArray.first {
                missingFields += "\(textFieldName)"
            } else if textFieldNamesArray.count == 2 && textFieldName == textFieldNamesArray.last {
                missingFields += " and \(textFieldName.lowercased())"
                
            } else if textFieldNamesArray.count > 2 {
                if textFieldName == textFieldNamesArray.last {
                    missingFields += "and \(textFieldName.lowercased())"
                    break
                }
                if textFieldName != textFieldNamesArray.first {
                missingFields += "\(textFieldName.lowercased()), "
                } else {
                missingFields += "\(textFieldName), "
                }
            }
        }
        
        var alertMessage = ""
        if textFieldNamesArray.count == 1 {
        let alertMessageSingular = "Missing field: \(missingFields)"
            alertMessage += alertMessageSingular
        } else if textFieldNamesArray.count > 1 {
            let alertMessagePlural = "Missing fields: \(missingFields)"
            alertMessage += alertMessagePlural
        }
        let missingFieldAlertController = UIAlertController(title: "Oops!", message: alertMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        missingFieldAlertController.addAction(alertAction)
        present(missingFieldAlertController, animated: true, completion: nil)
     
    }
    
}


