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
    
    @discardableResult func presentLoadingView() -> LoadingView {
        
        // Initialize the loading view.
        let loadingView: LoadingView = UIView.fromNib()
        
        // Add view and bring it to the front of the superview.
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
   
        // Add constraints
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: loadingView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: loadingView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        
        return loadingView
    }
    
    func toggleEnabledNavBarItems() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isUserInteractionEnabled = !navigationController.navigationBar.isUserInteractionEnabled
    }
    
    func toggleEnabledTabBarItems() {
        guard let tabBarController = tabBarController else { return }
        tabBarController.tabBar.isUserInteractionEnabled = !tabBarController.tabBar.isUserInteractionEnabled
    }
    
    @discardableResult func enableLoadingState() -> LoadingView {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let loadingView = presentLoadingView()
        toggleEnabledNavBarItems()
        toggleEnabledTabBarItems()
        return loadingView
    }
    
    func disableLoadingState(_ loadingView: LoadingView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        toggleEnabledNavBarItems()
        toggleEnabledTabBarItems()
        loadingView.removeFromSuperview()
    }
    
    func presentStandardAlertController(withTitle title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: completion)
        }
    }
}

extension Date {
    
    func short() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let date = dateFormatter.string(from: self)
        
        return date
    }
    
    func shortWithFullYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
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
}

extension UIView {
    
    static func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)!.first! as! T
    }
}

extension UIStoryboard {
    
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    static var onboarding: UIStoryboard {
        return UIStoryboard(name: "Onboarding", bundle: nil)
    }
}

extension UIView {
    
    func format() {
        self.layer.cornerRadius = 2
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.3
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        let bezierPath = UIBezierPath()
        
        // Start in the top lefthand corner
        bezierPath.move(to: CGPoint(x: self.frame.origin.x , y: self.frame.origin.y))
        
        // Move to the bottom lefthand corner
        bezierPath.addLine(to: CGPoint(x: self.frame.origin.x , y: self.frame.height))
        
//        // Move to the bottom righthand corner
//        bezierPath.addLine(to: CGPoint(x: self.frame.origin.x +  self.frame.width, y: self.frame.origin.y))
////
//        // Move to the top righthand corner
//        bezierPath.move(to: CGPoint(x: self.frame.origin.x + self.frame.width, y: self.frame.origin.y - self.frame.height))
        bezierPath.stroke()
        bezierPath.fill()
        self.layer.shadowPath = bezierPath.cgPath
    }
}

extension UIButton {
    
    func addBorder(with color: UIColor, andWidth width: CGFloat) {
        self.layer.cornerRadius = 14
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}

extension UIView {
    
    func formatLine() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.1
        self.layer.shadowRadius = 0.8
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}

struct Colorss {
    static let lightRed = UIColor(red: 255.0, green: 77.0, blue: 77.0, alpha: 0.0)
}
