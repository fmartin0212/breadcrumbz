//
//  OnboardingPageViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [viewController(identifier: "ExplanationViewController"), viewController(identifier: "FeaturesViewController"), viewController(identifier: "SignUp")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
    }
    
    private func viewController(identifier: String) -> UIViewController {
        let sb = UIStoryboard(name: "Onboarding", bundle: nil)
        let viewController = sb.instantiateViewController(withIdentifier: identifier)
        return viewController
    }

}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentVCIndex = orderedViewControllers.index(of: viewController) else { return nil }
       
        if currentVCIndex > 0 {
            let previousIndex = currentVCIndex - 1
            let previousVC = orderedViewControllers[previousIndex]
            return previousVC
            
        }
        else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentVCIndex = orderedViewControllers.index(of: viewController) else { return nil }
        
        if currentVCIndex < (orderedViewControllers.count - 1) {
            let nextIndex = currentVCIndex + 1
            let nextVC = orderedViewControllers[nextIndex]
            return nextVC
            
        }
        else {
            return nil }
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = orderedViewControllers.first,
        let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController)
        else { return 0 }
        
        return firstViewControllerIndex
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {}

