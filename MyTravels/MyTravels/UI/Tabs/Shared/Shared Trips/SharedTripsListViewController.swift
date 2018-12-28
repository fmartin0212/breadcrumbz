//
//  SharedTripsListViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class SharedTripsListViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var profileBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private var profileButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(fetchSharedTrips), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Constants.sharedTripsReceivedNotif, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePicture), name: Constants.profilePictureUpdatedNotif, object: nil)
        // Set tableview properties
        tableView.separatorStyle = .none
        
        // Set delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.refreshControl = refreshControl
        setupLeftBarButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: Constants.refreshSharedTripsListNotif, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
      checkForNoSharedTrips()
    }
    
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func fetchSharedTrips() {
        SharedTripsController.shared.fetchSharedTrips { (success) in
            if success {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()                    
                }
            }
        }
    }
    
    @objc func refreshTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.checkForNoSharedTrips()
        }
    }
    
    private func setupLeftBarButton() {
        let button = UIButton(type: .custom)
        let image = InternalUserController.shared.loggedInUser?.photo != nil ? InternalUserController.shared.loggedInUser?.photo : UIImage(named: "user")
        let resizedImage = image?.resize(to: CGSize(width: 35, height: 35))
        button.setImage(resizedImage, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 17.5
        button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        profileButton = button
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func profileButtonTapped() {
        
        if let _ = InternalUserController.shared.loggedInUser {
            let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC")
            UIView.animate(withDuration: 2) {
                self.present(profileVC, animated: true, completion: nil)
            }
        } else {
            let signUpVC = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "SignUp") as! SignUpViewController
            signUpVC.loadViewIfNeeded()
            signUpVC.skipButton.isHidden = true
            self.present(signUpVC, animated: true, completion: nil)
        }
    }
    
    @objc func updateProfilePicture() {
        let image = InternalUserController.shared.loggedInUser != nil ? InternalUserController.shared.loggedInUser!.photo : UIImage(named: "user")
        let resizedImage = image?.resize(to: CGSize(width: 35, height: 35))
        
        DispatchQueue.main.async {
            self.profileButton?.setImage(resizedImage, for: .normal)
            self.profileButton?.clipsToBounds = true
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSharedTripDetailViewSegue" {
            guard let destinationVC = segue.destination as? SharedTripDetailViewController,
                let indexPath = tableView.indexPathForSelectedRow
                else { return }
            let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
            destinationVC.sharedTrip = sharedTrip
            
        }
    }
    
    @IBAction func profileBarButtonItemTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "profileVC")
        UIView.animate(withDuration: 2) {
            self.present(profileVC, animated: true, completion: nil)
        }
    }
}

extension SharedTripsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedTripsController.shared.sharedTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) as! TripTableViewCell
        cell.selectionStyle = .none
        
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
        
        cell.sharedTrip = sharedTrip
        
        return cell
        
    }
}

extension SharedTripsListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sharedTrip = SharedTripsController.shared.sharedTrips[indexPath.row]
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let sharedTripDetailVC = sb.instantiateViewController(withIdentifier: "sharedTripDetail") as? SharedTripDetailViewController else { return }
        sharedTripDetailVC.sharedTrip = sharedTrip
        self.navigationController?.pushViewController(sharedTripDetailVC, animated: true)
    }
}

extension SharedTripsListViewController {
    
    func checkForNoSharedTrips() {
        if SharedTripsController.shared.sharedTrips.count == 0 {
            let noSharedTripsView: NoSharedTripsView = UIView.fromNib()
            view.addSubview(noSharedTripsView)
            noSharedTripsView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: noSharedTripsView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: noSharedTripsView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: noSharedTripsView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
            NSLayoutConstraint(item: noSharedTripsView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        }
    }
}
