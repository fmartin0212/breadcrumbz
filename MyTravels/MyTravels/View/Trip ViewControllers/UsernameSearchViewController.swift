//
//  UsernameSearchViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/14/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import Contacts

class UsernameSearchViewController: UIViewController {

    // MARK: - Properties
    var trip: Trip?
    var usernames = [String]()
    var arrayOfPhoneNumbers = [[String]]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingVisualEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let contactStore = CNContactStore()
        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor])
        try? contactStore.enumerateContacts(with: fetchRequest) { (contact, _) in
            DispatchQueue.main.async {
                let firstName = contact.givenName
                let lastName = contact.familyName
                guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else { return }
                //            print("CONTACT INFORMATION: \(firstName) \(lastName),\(phoneNumber)")
                var phoneNumberArray = [String]()
                for character in phoneNumber.unicodeScalars {
                    let characterAsString = String(character)
                    if character.value >= 48 && character.value < 58 {
                        phoneNumberArray.append(characterAsString)
                        
                    }
                    
                }
                if Int(phoneNumberArray.first!) == 1 {
                    phoneNumberArray.remove(at: 0)
                }
                //                print("\(firstName), \(lastName), \(phoneNumberArray)")
                self.arrayOfPhoneNumbers.append(phoneNumberArray)
                print("adsf")
            }
            
        }
        
        for phoneNumberArray in self.arrayOfPhoneNumbers {
            print("PHONE NUMBER ARRAYS: \(phoneNumberArray)")
        }
        print(self.arrayOfPhoneNumbers.count)
        
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
        guard let trip = trip else { return }
        loadingVisualEffectView.alpha = 1
        
        let username = usernames[indexPath.row]
        
        CloudKitManager.shared.fetchTripShareReceiverWith(username: username) { (user) in
            guard let user = user else { return }
            SharedTripsController.shared.addSharedIDTo(trip: trip, forUser: user)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, animations: {
                    self.loadingVisualEffectView.alpha = 0
                }, completion: { (success) in
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
}

