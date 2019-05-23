//
//  OnboardingParentViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 3/20/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class OnboardingParentViewController: UIViewController {

    @IBOutlet weak var containterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    lazy var pageViewController: OnboardingPageViewController? = {
        guard let pageViewController = self.children.first as? OnboardingPageViewController else { return nil }
        return pageViewController
    }()
    lazy var currentViewController: UIViewController? = {
        guard let pageViewController = self.pageViewController,
        let firstVC = pageViewController.orderedViewControllers.first
            else { return nil }
        return firstVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.clipsToBounds = true
        pageViewController?.onboardingDelegate = self
        NotificationCenter.default.addObserver(forName: Constants.viewWillAppearForVC, object: nil, queue: nil) { [weak self] (notification) in
            self?.handle(notification)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.removeObserver(self, name: Constants.viewWillAppearForVC, object: nil)
    }
    
    func handle(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        currentViewController = userInfo["viewController"] as? UIViewController
        if currentViewController is SignUpVC {
            containterViewHeightConstraint =  NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        } else {
            containterViewHeightConstraint =  NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.6, constant: 0)
            view.layoutIfNeeded()
        }
        print("foo")
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        UserDefaults.standard.setValue(true, forKey: "userSkippedSignUp")
        presentTripListVC()
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let pageViewController = self.pageViewController,
            let currentViewController = currentViewController,
            let nextVC = pageViewController.pageViewController(pageViewController, viewControllerAfter: currentViewController)
            else { return }
        pageViewController.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
            containterViewHeightConstraint =  NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        print("foo")
    }
}

extension OnboardingParentViewController: OnboardingPageViewControllerDelegate {
    func viewControllerAppeared(viewController: UIViewController) {
        self.currentViewController = viewController
    }
}
