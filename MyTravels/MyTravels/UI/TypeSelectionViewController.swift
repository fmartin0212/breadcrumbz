//
//  TypeSelectionViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/2/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

protocol TypeSelectionViewControllerDelegate: class {
    func set(type: String)
}

class TypeSelectionViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var lodgingButton: UIButton!
    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: TypeSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setPropertiesFor(overlayView: overlayView)
        
        // Format button properties
        lodgingButton.layer.cornerRadius = 8
        restaurantButton.layer.cornerRadius = 8
        activityButton.layer.cornerRadius = 8
    }

    @IBAction func lodgingButtonTapped(_ sender: UIButton) {
        
        //FIXME: - refactor to use function, pass in button text
        UIView.animate(withDuration: 0.10, animations: {
            self.lodgingButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.10, animations: {
                    self.lodgingButton.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    self.delegate?.set(type: "Lodging")
                    self.dismiss(animated: true, completion: nil)
                })
        }
        
    }
    
    @IBAction func restaurantButtonTapped(_ sender: UIButton) {
       
        UIView.animate(withDuration: 0.10, animations: {
            self.restaurantButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.10, animations: {
                self.restaurantButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                self.delegate?.set(type: "Restaurant")
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func activityButtonTapped(_ sender: UIButton) {

        UIView.animate(withDuration: 0.10, animations: {
            self.activityButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }) { (_) in
            UIView.animate(withDuration: 0.10, animations: {
                self.activityButton.transform = CGAffineTransform.identity
            }, completion: { (_) in
                self.delegate?.set(type: "Activity")
                self.dismiss(animated: true, completion: nil)
            })
        }
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
