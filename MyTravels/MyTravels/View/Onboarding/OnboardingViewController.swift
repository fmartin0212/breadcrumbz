//
//  OnboardingViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/12/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    let pageViewController = UIPageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController.delegate = self
        pageViewController.dataSource = self

    }

}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
}


extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
    }
    
    
}
