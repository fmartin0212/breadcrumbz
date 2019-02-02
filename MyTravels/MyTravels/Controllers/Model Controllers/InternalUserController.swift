//
//  UserController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class InternalUserController {
    
    static var shared = InternalUserController()
    
    var loggedInUser: InternalUser?
    
    func createNewUserWith(firstName: String, lastName: String?, username: String, email: String, password: String, completion: @escaping (String?) -> Void) {
        
        // Initialize a new user
        let newUser = InternalUser(firstName: firstName, lastName: lastName, username: username, email: email)

        // Save the user to Firebase Auth
        FirebaseManager.addUser(with: email, password: password, username: username) { (firebaseUser, errorMessage) in
            if let errorMessage = errorMessage {
                print("Error saving a new user to the Firebase Database: \(errorMessage)")
                completion(errorMessage)
                return
            }
            
            guard let _ = firebaseUser else { completion(Constants.somethingWentWrong) ; return }
            
            // Save the user to the Firebase Database
            FirebaseManager.save(newUser, uuid: firebaseUser?.uid, completion: { (errorMessage, uuid) in
                if let errorMessage = errorMessage {
                    completion(errorMessage)
                    return
                } else {
                    newUser.uuid = uuid
                    self.loggedInUser = newUser
                    completion(nil)
                }
            })
        }
    }
    
    func checkForLoggedInUser(completion: @escaping (Bool) -> Void) {
        if let firebaseUser = FirebaseManager.getLoggedInUser() {
            FirebaseManager.fetch(uuid: firebaseUser.uid, completion: { (loggedInUser: InternalUser?) in
                guard let loggedInUser = loggedInUser else { completion(false) ; return  }
                self.loggedInUser = loggedInUser
                completion(true)
            }
        )} else {
            completion(false)
        }
    }
    
    func login(withEmail email: String, password: String, completion: @escaping (String?) -> Void) {
        FirebaseManager.login(withEmail: email, and: password) { (firebaseUser, errorMessage) in
            if let errorMessage = errorMessage {
                print("Error logging in Firebase user : \(errorMessage)")
                completion(errorMessage)
                return
            } else {
                guard let uuid = firebaseUser?.uid else { completion(nil) ; return }
                
                FirebaseManager.fetch(uuid: uuid, atChildren: nil, completion: { (loggedInUser: InternalUser?) in
                    guard let loggedInUser = loggedInUser else { completion(Constants.somethingWentWrong) ; return  }
                    self.loggedInUser = loggedInUser
                    completion(nil)
                })
            }
        }
    }
    
    func logOut() {
        FirebaseManager.logOutUser()
        InternalUserController.shared.loggedInUser = nil
        SharedTripsController.shared.clearSharedTrips()
    }
    
    func saveProfilePhoto(photo: UIImage, for user: InternalUser, completion: @escaping (Bool) -> Void) {
        let ref = FirebaseManager.ref.child("User").child(user.uuid!).child("photoURL")
        let storeRef = FirebaseManager.storeRef.child("User").child(user.uuid!).child("photo")
        
        guard let imageAsData = UIImageJPEGRepresentation(photo, 0.1) else { completion(false) ; return }
        
        FirebaseManager.save(data: imageAsData, to: storeRef) { (metadata, error) in
            if let error = error {
                print("There was an error saving the profile picture to Firebase: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            user.photoURL = metadata?.downloadURL()?.absoluteString
            user.photo = photo
            
            FirebaseManager.save(metadata?.downloadURL()?.absoluteString as Any, to: ref, completion: { (error) in
                if let error = error {
                    print("There was an error saving the photo URL to the Firebase DB: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                completion(true)
            })
        }
    }
    
    func fetchProfilePhoto(from urlAsString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlAsString) else { completion(nil) ; return }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("There was an error retrieving the profile photo from Firebase: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = data else { completion(nil) ; return }
            let image = UIImage(data: data)
            completion(image)
        }
        dataTask.resume()
    }
    
    func blockUserWith(username: String, completion: @escaping (Bool) -> Void) {
        // Add user to loggedInUser's blocked list
        let blockRef = FirebaseManager.ref.child("User").child(loggedInUser!.username).child("blockedUsernames").child(username)
        FirebaseManager.save(username, to: blockRef) { (error) in
            if let error = error {
                print("There was an error saving the username to the loggedInUser's blockedUser list : \(error.localizedDescription)")
                completion(false)
                return
            } else {
                // Unwrap logged in user's participant trip IDs
                guard var loggedInUserPartcipantIDs = InternalUserController.shared.loggedInUser!.participantTripIDs else { completion(false) ; return }
                
                // Fetch all the sharedTripIDs for the user that is going to be blocked
                let ref =  FirebaseManager.ref.child("User").child(username).child("sharedTripIDs")
                FirebaseManager.fetchObject(from: ref) { (snapshot) in
                    guard let sharedTripIDDictionary = snapshot.value as? [String : Any] else { completion(false) ; return }
                    let sharedTripIDs = sharedTripIDDictionary.compactMap { $0.key }
                    
                    // Remove the participantTripIDs for the logged in user if it matches a sharedTripID from the blocked user.
                    for participantTripID in loggedInUserPartcipantIDs {
                        if sharedTripIDs.contains(participantTripID) {
                            guard let index = loggedInUserPartcipantIDs.firstIndex(of: participantTripID) else { completion(false) ; return }
                            loggedInUserPartcipantIDs.remove(at: index)
                            print("break")
                        }
                    }
                    
                    // Update Firebase
                    // If loggedInUserPartcipantIDs.count is 0, then all of the user's shared trips were from the blocked user; therefore, this node can be removed altogether.
                    if loggedInUserPartcipantIDs.count == 0 {
                        let ref = FirebaseManager.ref.child("User").child(self.loggedInUser!.username).child("participantTripIDs")
                        FirebaseManager.removeObject(ref: ref, completion: { (error) in
                            if let error = error {
                                print("error saving tripID : \(error.localizedDescription)")
                                completion(false)
                                return
                            }
                            
                            let sharedTrips = SharedTripsController.shared.sharedTrips.filter { $0.creatorUsername != username }
                            SharedTripsController.shared.sharedTrips = sharedTrips
                            
                            completion(true)
                            return
                        })
                    } else {
                        
                        let dispatchGroup = DispatchGroup()
                        for participantTripID in loggedInUserPartcipantIDs {
                            let ref = FirebaseManager.ref.child("User").child(self.loggedInUser!.username).child("participantTripIDs").child(participantTripID)
                            dispatchGroup.enter()
                            FirebaseManager.save(participantTripID, to: ref, completion: { (error) in
                                if let error = error {
                                    print("error saving tripID : \(error.localizedDescription)")
                                    completion(false)
                                    return
                                }
                                dispatchGroup.leave()
                            })
                        }
                        
                  
                        dispatchGroup.notify(queue: .main, execute: {
                            let sharedTrips = SharedTripsController.shared.sharedTrips.filter { $0.creatorUsername != username }
                            SharedTripsController.shared.sharedTrips = sharedTrips
                            
                            self.loggedInUser!.participantTripIDs = loggedInUserPartcipantIDs
                            completion(true)
                        })
                    }
                }
            }
        }
    }
}
