//
//  CreateAccountViewController
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    
    var centerX: NSLayoutConstraint?
    var centerY: NSLayoutConstraint?
    var startingPoint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set view's edges to be round
        overlayView.layer.cornerRadius = 8
        
        // Set button border properties
        setPropertiesFor(button: createAccountButton)
        
        // Format overlayview
        setPropertiesFor(overlayView: overlayView)
        
        // Overlay fade in animation
        fadeInOverlayView()
        
    }
    
    // MARK: - IBActions
    
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        // Create bubbly effect upon tap
        UIView.animate(withDuration: 0.10, animations: {
            self.createAccountButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.10, animations: {
                self.createAccountButton.transform = CGAffineTransform.identity
            })
        }
        
        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let username = phoneNumberTextField.text,
            let placeholderProfilePicture = UIImage(named: "user")
            else { return }
        
        let placeholderProfilePictureAsData = placeholderProfilePicture.jpegData(compressionQuality: 0.1)
        
      
    }
    
    // MARK: - Functions
    
    func fadeInOverlayView() {
        let transform = CATransform3DTranslate(CATransform3DIdentity, 0, 200, 0)
        overlayView.layer.transform = transform
        overlayView.alpha = 0
        
        UIView.animate(withDuration: 0.75) {
            self.overlayView.alpha = 1.0
            self.overlayView.layer.transform = CATransform3DIdentity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        overlayView.endEditing(true)
    }
}

