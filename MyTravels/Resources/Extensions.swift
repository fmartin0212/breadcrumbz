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
