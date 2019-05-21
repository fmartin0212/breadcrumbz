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
                
            case .success(let user):
                newUser.uuid = user.uid
                // Save InternalUser object to Firestore
                self?.firestoreService.save(object: newUser, completion: { (result) in
                    switch result {
                    
                    case .failure(let error):
                        // FIXME: - failure should not pass .generic
                        completion(.failure(error))
                    case .success(_):
                        
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
        } else {
            completion(.failure(.generic))
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
        PhotoController.shared.savePhoto(photo: photo, for: user) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(true))
            }
        }
    }
    
    func fetchProfilePhoto(from path: String, completion: @escaping (Result<UIImage, FireError>) -> Void) {
            if let image = CacheManager.shared.queryImageCache(path: path) {
                completion(.success(image))
                return
            }
            
            PhotoController.shared.fetchPhoto(withPath: path) { (result) in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let image):
                    
                    completion(.success(image))
                }
            }
    }
    
    func blockUserWith(creatorID: String, completion: @escaping (Result<Bool, FireError>) -> Void) {
        
        guard let loggedInUser = InternalUserController.shared.loggedInUser else { completion(.failure(.generic)) ; return }
        // Add user to loggedInUser's blocked list
        firestoreService.update(object: loggedInUser, atField: "blockedUserIDs", withCriteria: [creatorID], with: .arrayAddition) { [weak self] (result) in
            switch result {
                
            case .failure(let error):
                completion(.failure(error))
                
            case .success(_):
                self?.firestoreService.fetch(uuid: nil, field: "uuid", criteria: creatorID, queryType: .fieldEqual, completion: { (result: Result<[InternalUser], FireError>) in
                    switch result {
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .success(let blockedUserArray):
                        guard let blockedUser = blockedUserArray.first,
                            let blockedUserSharedTripIDs = blockedUser.sharedTripIDs
                            else { completion(.failure(.generic)) ; return }
                        
                        self?.firestoreService.update(object: loggedInUser, atField: "participantTripIDs", withCriteria: blockedUserSharedTripIDs, with: .arrayDeletion, completion: { (result) in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(_):
                                completion(.success(true))
                            }
                        })
                    }
                })
            }
        }
    }
    
    
    func updateUser(name: String?, username: String?, email: String?, password: String?, completion: @escaping (Bool) -> Void) {
        
    }
}

