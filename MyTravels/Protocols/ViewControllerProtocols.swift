//
//  ViewControllerProtocols.swift
//  MyTravels
//
//  Created by Frank Martin on 3/1/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

protocol ScrollableViewController where Self: UIViewController {
    var contentView: UIView! { get }
    var scrollView: UIScrollView! { get }
    var selectedTextField: UITextField? { get set }
    var selectedTextView: UITextView? { get set }
    func adjustScrollView(keyboardFrame: CGRect)
}

extension ScrollableViewController {
    func adjustScrollView(keyboardFrame: CGRect) {
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        self.view.layoutIfNeeded()
        
        if let selectedTextField = selectedTextField, selectedTextField.isEditing {
            // Convert text field's bounds to content view
            let trueFrame = selectedTextField.convert(selectedTextField.bounds, to: self.contentView)
            let offsetPoint = CGPoint(x: 0, y: (trueFrame.origin.y - selectedTextField.frame.height))
            self.scrollView.setContentOffset(offsetPoint, animated: true)
            return
        }
        
        if let selectedTextView = self.selectedTextView {
            let trueFrame = selectedTextView.convert(selectedTextView.bounds, to: self.contentView)
            let offsetPoint = CGPoint(x: 0, y: trueFrame.origin.y - (selectedTextView.frame.height / 3))
            self.scrollView.setContentOffset(offsetPoint, animated: true)
            return
        }
    }
}

