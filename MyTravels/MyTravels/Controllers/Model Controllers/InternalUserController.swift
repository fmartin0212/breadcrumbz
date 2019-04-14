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
    let firebaseAuthService: FirebaseAuthServiceProtocol
    let firestoreService: FirestoreServiceProtocol
    let firebaseStorageService: FirebaseStorageServiceProtocol
    
    init() {
        self.firebaseAuthService = FirebaseAuthService()
        self.firestoreService = FirestoreService()
    }
    
    func createNewUserWith(firstName: String,
                           lastName: String?,
                           username: String,
                           email: String,
                           password: String,
                           completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        // Initialize a new user
        let newUser = InternalUser(firstName: firstName, lastName: lastName, username: username, email: email)
        
        // Save the user to Firebase Auth
        firebaseAuthService.addUser(with: email, password: password, username: username) { [weak self] (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                // Save InternalUser object to Firestore
                self?.firestoreService.save(object: newUser, completion: { (result) in
                    switch result {
                    case .failure(let error):
                        // FIXME: - failure should not pass .generic
                        completion(.failure(error))
                    case .success(let uuid):
                        newUser.uuid = uuid
                        self?.loggedInUser = newUser
                        completion(.success(true))
                    }
                })
            }
        }
    }
    
    func checkForLoggedInUser(completion: @escaping (Result<Bool, FireError>) -> Void) {
        if let firebaseUser = firebaseAuthService.getLoggedInUser() {
            firestoreService.fetch(uuid: firebaseUser.uid, field: nil, criteria: nil, queryType: nil) { (result: Result<[InternalUser], FireError>) in
                switch result {
                    
                case .failure(let error):
                    completion(.failure(error))
                    
                case .success(let results):
                    let loggedInUser = results.first!
                    self.loggedInUser = loggedInUser
                    completion(.success(true))
                }
            }
        }
    }
    
    func login(withEmail email: String, password: String, completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        firebaseAuthService.login(withEmail: email, and: password) { [weak self] (result) in
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let user):
                self?.firestoreService.fetch(uuid: user.uid, field: nil, criteria: nil, queryType: nil) { (result: Result<[InternalUser], FireError>) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let results):
                        let loggedInUser = results.first!
                        self?.loggedInUser = loggedInUser
                        completion(.success(true))
                    }
                }
            }
        }
    }
    
    func logOut() {
        firebaseAuthService.logOutUser()
        InternalUserController.shared.loggedInUser = nil
        SharedTripsController.shared.clearSharedTrips()
    }
    
    func saveProfilePhoto(photo: UIImage,
                          for user: InternalUser,
                          completion: @escaping (Result<Bool, FireError>) -> Void) {
        guard let imageAsData = photo.jpegData(compressionQuality: 0.1) else { completion(.failure(.generic)) ; return }
        
        let photo = Photo(photo: imageAsData, place: nil, trip: nil)
        
        firebaseStorageService.save(photo) { [weak self] (result) in
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let path):
                self?.firestoreService.update(object: user, atChildren: ["photoPath" : path], completion: { (result) in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(_):
                        completion(.success(true))
                    }
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
        
        func blockUserWith(creatorID: String, completion: @escaping (String?) -> Void) {
            // Add user to loggedInUser's blocked list
            let blockRef = FirebaseManager.ref.child("User").child(loggedInUser!.uuid!).child("blockedUserIDs")
            FirebaseManager.updateObject(at: blockRef, value: [creatorID : true]) { (errorMessage) in
                if let errorMessage = errorMessage {
                    print("There was an error saving the username to the loggedInUser's blockedUser list : \(errorMessage)")
                    completion(errorMessage)
                    return
                } else {
                    // Unwrap logged in user's participant trip IDs
                    guard let loggedInUserPartcipantIDs = InternalUserController.shared.loggedInUser!.participantTripIDs else { completion(Constants.somethingWentWrong) ; return }
                    
                    // Fetch all the sharedTripIDs for the user that is going to be blocked
                    let ref =  FirebaseManager.ref.child("User").child(creatorID).child("sharedTripIDs")
                    FirebaseManager.fetchObject(from: ref) { (snapshot) in
                        guard let sharedTripIDDictionary = snapshot.value as? [String : Any] else { completion(Constants.somethingWentWrong) ; return }
                        let sharedTripIDs = sharedTripIDDictionary.compactMap { $0.key }
                        
                        // Remove the participantTripIDs for the logged in user if it matches a sharedTripID from the blocked user.
                        let participantTripIDs = loggedInUserPartcipantIDs.filter { !sharedTripIDs.contains($0) }
                        
                        var participantTripIDDictionary: [String : Any] = [:]
                        participantTripIDs.forEach { participantTripIDDictionary[$0] = true }
                        
                        FirebaseManager.overwrite(self.loggedInUser!, atChildren: ["participantTripIDs"], withValues: participantTripIDDictionary, completion: { (errorMessage) in
                            if let errorMessage = errorMessage {
                                completion(errorMessage)
                                return
                            } else {
                                let sharedTrips = SharedTripsController.shared.sharedTrips.filter { $0.creatorID != creatorID }
                                SharedTripsController.shared.sharedTrips = sharedTrips
                                self.loggedInUser!.participantTripIDs = loggedInUserPartcipantIDs
                                completion(nil)
                            }
                        })
                    }
                }
            }
        }
        
        func updateUser(name: String?, username: String?, email: String?, password: String?, completion: @escaping (Bool) -> Void) {
            
        }
    }
}
