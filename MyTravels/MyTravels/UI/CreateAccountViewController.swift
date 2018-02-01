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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    var centerX: NSLayoutConstraint?
    var centerY: NSLayoutConstraint?
    var startingPoint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set view's edges to be round
        overlayView.layer.cornerRadius = 8
        
        // Set button border properties
        createAccountButton.layer.cornerRadius = 8
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.borderColor = #colorLiteral(red: 0.5557265282, green: 0.7272669077, blue: 0.6576992273, alpha: 1)
        
        // Overlay fade in animation
        fadeInOverlayView()
        
    }
    
    // MARK: - IBActions
    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        
        // Create bubbly effect upon tap
        UIView.animate(withDuration: 0.15, animations: {
            self.createAccountButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.15, animations: {
                self.createAccountButton.transform = CGAffineTransform.identity
            })
        }
        
    }
    
    // MARK: - Functions
    func fadeInOverlayView() {
        
        let transform = CATransform3DTranslate(CATransform3DIdentity, 0, 200, 0)
        overlayView.layer.transform = transform
        overlayView.alpha = 0
        
        UIView.animate(withDuration: 1.0) {
            self.overlayView.alpha = 1.0
            self.overlayView.layer.transform = CATransform3DIdentity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        overlayView.endEditing(true)
    }
    
}

