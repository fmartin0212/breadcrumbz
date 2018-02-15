//
//  UsernameSearchViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/14/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class UsernameSearchViewController: UIViewController {

    // MARK: - Properties
    var trip: Trip?
    var usernames = [String]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingVisualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
        // Delegates
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        view.isUserInteractionEnabled = false
        CloudKitManager.shared.performFullSync { (success) in
            
            CloudKitManager.shared.fetchAllUsers { (usernames) in
                self.usernames = usernames
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2) {
                        self.loadingVisualEffectView.alpha = 0
                    }
                    self.tableView.reloadData()
                    
                    self.view.isUserInteractionEnabled = true
                }
            }
        }
        
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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

extension UsernameSearchViewController: UISearchBarDelegate {
    
}

extension UsernameSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = usernames[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadingVisualEffectView.alpha = 1
        let username = usernames[indexPath.row]
        
        
    }
}

