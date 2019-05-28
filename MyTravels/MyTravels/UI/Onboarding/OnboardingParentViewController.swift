//
//  OnboardingParentViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 3/20/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class OnboardingParentViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var topRightSkipButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var bottomLeftSkipButton: UIButton!
    
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
        if let signUpVC = currentViewController as? SignUpVC {
            topRightSkipButton.isHidden = false
            nextButton.isHidden = true
            bottomLeftSkipButton.isHidden = true
            signUpVC.scrollView.delegate = self
        } else {
            topRightSkipButton.isHidden = true
            nextButton.isHidden = false
            bottomLeftSkipButton.isHidden = false
        }
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
    }
}

extension OnboardingParentViewController: OnboardingPageViewControllerDelegate {
    func viewControllerAppeared(viewController: UIViewController) {
        self.currentViewController = viewController
    }
}

extension OnboardingParentViewController: UIScrollViewDelegate {

//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y > 40 {
//            topRightSkipButton.isHidden = true
//        }
//    }
    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print(scrollView.contentOffset)
//   
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 40 {
            topRightSkipButton.isHidden = false
        } else {
            topRightSkipButton.isHidden = true
        }
    }
}
