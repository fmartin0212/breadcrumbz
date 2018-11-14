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
    
    func createNewUserWith(firstName: String, lastName: String?, username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        let newUser = InternalUser(firstName: firstName, lastName: lastName, username: username, email: email)
        FirebaseManager.addUser(with: email, password: password, username: username) { (firebaseUser, error) in
            if let error = error {
                // FIXME - Should switch on an enum
                print("Error saving a new user to the Firebase Database: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let firebaseUser = firebaseUser else { completion(false) ; return }
//            newUser.uid = firebaseUser.uid
            self.loggedInUser = newUser
            
            let internalUserDict: [String : Any] = [ "username" : newUser.username,
                            "email" : newUser.email,
                            "firstName" : newUser.firstName,
                            "lastName" : newUser.lastName ?? ""
                            ]
            
            let ref = FirebaseManager.ref.child("User").child(username)
            FirebaseManager.save(object: internalUserDict, to: ref, completion: { (error) in
                if let error = error {
                    // Present alert controller?
                } else {
                    completion(true)
                }
            })
        }
    }
    
    func checkForLoggedInUser(completion: @escaping (Bool) -> Void) {
        if let firebaseUser = FirebaseManager.getLoggedInUser() {
            let ref = FirebaseManager.ref.child("User").child(firebaseUser.displayName!)
            FirebaseManager.fetchObject(from: ref) { (snapshot) in
                let loggedInUser = InternalUser(snapshot: snapshot)
                self.loggedInUser = loggedInUser
                completion(true)
                return
            }
        } else {
            completion(false)
        }
    }
    
    func saveProfilePhoto(photo: UIImage, for user: InternalUser, completion: @escaping (Bool) -> Void) {
        let ref = FirebaseManager.ref.child("User").child(user.username).child("photoURL")
        let storeRef = FirebaseManager.storeRef.child("User").child(user.username).child("photo")
        
        guard let imageAsData = UIImagePNGRepresentation(photo) else { completion(false) ; return }
        
        FirebaseManager.save(data: imageAsData, to: storeRef) { (metadata, error) in
            if let error = error {
                print("There was an error saving the profile picture to Firebase: \(error.localizedDescription)")
                 completion(false)
                return
            }
            
            user.photoURL = metadata?.downloadURL()?.absoluteString
            user.photo = photo
            
            FirebaseManager.saveSingleObject(metadata?.downloadURL()?.absoluteString as Any, to: ref, completion: { (error) in
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
       // Unwrap logged in user's participant trip IDs
        guard let loggedInUserPartcipantIDs = InternalUserController.shared.loggedInUser!.participantTripIDs else { completion(false) ; return }
        
        // Fetch all the sharedTripIDs for the user that is going to be blocked
        let ref =  FirebaseManager.ref.child("User").child(username).child("sharedTripIDs")
        FirebaseManager.fetchObject(from: ref) { (snapshot) in
            guard let sharedTripIDDictionary = snapshot.value as? [String : Any] else { completion(false) ; return }
            let sharedTripIDs = sharedTripIDDictionary.compactMap { $0.key }
            
            
            // Remove the participantTripIDs for the logged in user if it matches a sharedTripID from the blocked user.
            for participantTripID in loggedInUserPartcipantIDs {
                if sharedTripIDs.contains(participantTripID) {
                    guard let index = loggedInUserPartcipantIDs.firstIndex(of: participantTripID) else { completion(false) ; return }
                    self.loggedInUser!.participantTripIDs?.remove(at: index)
                    print("break")
                }
            }
           
            // Update Firebase
            let dispatchGroup = DispatchGroup()
            guard let loggedInUserPartcipantIDs = self.loggedInUser!.participantTripIDs else { completion(false) ; return }
           
            for participantTripID in loggedInUserPartcipantIDs {
                 let ref = FirebaseManager.ref.child("User").child(self.loggedInUser!.username).child("participantTripIDs").child(participantTripID)
                dispatchGroup.enter()
                FirebaseManager.saveSingleObject(participantTripID, to: ref, completion: { (error) in
                    if let error = error {
                        print("error saving tripID : \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue: .main, execute: {
                completion(true)
            })
        }
    }
}
