//
//  OnboardingParentViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 3/20/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class OnboardingParentViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.clipsToBounds = true
        let child = self.childViewControllers.first! as! OnboardingPageViewController
    }
    @IBAction func skipButtonTapped(_ sender: Any) {
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
    }
}
