////
////  UsernameSearchViewController.swift
////  MyTravels
////
////  Created by Frank Martin Jr on 2/14/18.
////  Copyright © 2018 Frank Martin Jr. All rights reserved.
////
//
//import UIKit
//import Contacts
//import CloudKit
//
//class UsernameSearchViewController: UIViewController {
//
//    // MARK: - Properties
//    var trip: Trip?
//    var usernames = [String]()
//    var users = [User]()
//    var arrayOfPhoneNumbers = [String]()
//    var loggedInUsersFriends = [User]()
//
//    // MARK: - IBOutlets
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var loadingVisualEffectView: UIVisualEffectView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Delegates
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        view.isUserInteractionEnabled = false
//
//        // Sync all user's trips/places
//        CloudKitManager.shared.performFullSync { (success) in
//            self.fetchContacts { (_) in }
//
//            var allUsers = [User]()
//            var loggedInUsersFriends = [User]()
//            print("full array of phone numbers: \(self.arrayOfPhoneNumbers)")
//            print("count of number of phone numbers: \(self.arrayOfPhoneNumbers.count)")
//
//            let predicate = NSPredicate(value: true)
//            let query = CKQuery(recordType: "User", predicate: predicate)
//            CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
//                if let error = error {
//                    print("error retrieving all users. \(error)")
//                }
//
//                guard let records = records else { return }
//                print("number of records: \(records.count)")
//                for record in records {
//                    guard let user = User(ckRecord: record) else { return }
//                    allUsers.append(user)
//                }
//
//                for user in allUsers {
////                    guard let userPhoneNumber = user.phoneNumber else { continue }
////                    if self.arrayOfPhoneNumbers.contains(userPhoneNumber) {
////                        loggedInUsersFriends.append(user)
////                        print("adsf")
//                    }
////                    self.loggedInUsersFriends = loggedInUsersFriends
//
//                    DispatchQueue.main.async {
//                        UIView.animate(withDuration: 0.2) {
//                            self.loadingVisualEffectView.alpha = 0
//                        }
//
//                        self.tableView.reloadData()
//
//                        self.view.isUserInteractionEnabled = true
//                    }
//                })
//            }
//        }
//    }
//
//    func fetchContacts(completion: @escaping (Bool) -> Void) {
//        let contactStore = CNContactStore()
//        let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor])
//        try? contactStore.enumerateContacts(with: fetchRequest) { (contact, _) in
//            guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else { completion(false) ; return }
//            var phoneNumberArray = [String]()
//            for character in phoneNumber.unicodeScalars {
//                let characterAsString = String(character)
//                if character.value >= 48 && character.value < 58 {
//                    phoneNumberArray.append(characterAsString)
//
//                }
//            }
//            if Int(phoneNumberArray.first!) == 1 {
//                phoneNumberArray.remove(at: 0)
//            }
//            var phoneNumberString = ""
//            for number in phoneNumberArray {
//                phoneNumberString += number
//            }
//            self.arrayOfPhoneNumbers.append(phoneNumberString)
//
//        }
//        completion(true)
//    }
//
//    @IBAction func cancelButtonTapped(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil)
//    }
//}
//
//extension UsernameSearchViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return loggedInUsersFriends.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
//        cell.textLabel?.text = loggedInUsersFriends[indexPath.row].firstName
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        loadingVisualEffectView.alpha = 1
//
//        guard let trip = trip else { return }
//
//        let user = loggedInUsersFriends[indexPath.row]
//
//        guard let tripReference = trip.reference else { return }
//
//        // If anything is in the user's pending refs list, append the new tripReference; otherwise, set the refs list to a new array with the trip reference.
////        if let userPendingSharedTripsRefs = user.pendingSharedTripsRefs {
//        if user.pendingSharedTripsRefs.contains(tripReference) {
//            self.loadingVisualEffectView.alpha = 0
//            let alert = UIAlertController(title: "Oops!", message: "You have already shared this trip with this user. Please choose someone else.", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
//            return
//        } else {
//            user.pendingSharedTripsRefs.append(tripReference)
//            //        } else {
//            //            user.pendingSharedTripsRefs = [tripReference]
//        }
//
//    guard let record = CKRecord(user: user) else { return }
//        CloudKitManager.shared.updateOperation(records: [record]) { (_) in
//            DispatchQueue.main.async {
//                self.loadingVisualEffectView.alpha = 0
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
//    }
//}
//

