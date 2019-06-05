//
//  Coordinator.swift
//  
//
//  Created by Frank Martin on 6/5/19.
//

import UIKit

class Coordinator {
    
    let window = UIApplication.shared.windows.first!
    
    var tripTabBarController: UITabBarController = {
        let tripTabBarController = UITabBarController()
        let myTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let myTripsNavigationController = UINavigationController(rootViewController: myTripListVC)
        let sharedTripListVC = TripListVC(nibName: "TripListVC", bundle: nil)
        let profileVC = UIStoryboard.profile.instantiateViewController(withIdentifier: "ProfileNavController")
        sharedTripListVC.state = .shared
        let mySharedTripsNavigationController = UINavigationController(rootViewController: sharedTripListVC)
        tripTabBarController.setViewControllers([myTripsNavigationController, mySharedTripsNavigationController, profileVC], animated: true)
        tripTabBarController.tabBar.items!.first!.title = "My Trips"
        tripTabBarController.tabBar.items!.first!.image = UIImage(named: "MyTrips")
        tripTabBarController.tabBar.items![1].title = "Shared"
        tripTabBarController.tabBar.items![1].image = UIImage(named: "Shared")
        tripTabBarController.tabBar.items![2].title = "Profile"
        tripTabBarController.tabBar.items![2].image = UIImage(named: "User")
        tripTabBarController.tabBar.backgroundColor = UIColor.white
        return tripTabBarController
    }()
    
    init() {}
    
    func presentMainTabBar() {
        window.rootViewController = tripTabBarController
    }
    
}
