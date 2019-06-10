//
//  FirebaseAuthService.swift
//  MyTravels
//
//  Created by Frank Martin on 4/14/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol FirebaseAuthServiceProtocol {
    func addUser(with email: String, password: String, username: String, completion: @escaping (Result<User, FireError>) -> Void)
    func login(withEmail email: String, and password: String, completion: @escaping (Result<User, FireError>) -> Void)
    func getLoggedInUser() -> User?
    func logOutUser()
}

public struct FirebaseAuthService: FirebaseAuthServiceProtocol {
    
    func addUser(with email: String,
                 password: String,
                 username: String,
                 completion: @escaping (Result<User, FireError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        completion(.failure(.emailAlreadyInUse))
                    case .invalidEmail:
                        completion(.failure(.invalidEmail))
                    case .weakPassword:
                        completion(.failure(.weakPassword))
                    default:
                        completion(.failure(.generic))
                    }
                    print("There was an error creating a new user: \(error.localizedDescription)")
                    return
                }
            }
            
            guard let authDataResult = authDataResult else { completion(.failure(.generic)) ; return }
            completion(.success(authDataResult.user))
//            // Update displayName in Authentication storage
//            let changeRequest = authDataResult.user.createProfileChangeRequest()
//            changeRequest.displayName = username
//            changeRequest.commitChanges(completion: { (error) in
//                if let error = error {
//                    print(error as Any)
//                    completion(.failure(.generic))
//                    return
//                }
        }
    }
    
    func login(withEmail email: String,
               and password: String,
               completion: @escaping (Result<User, FireError>) -> Void) {
        
        Auth.auth().signIn(withEmail: email,
                           password: password) { (authDataResult, error) in
            if let error = error {
                if let errorCode = AuthErrorCode(rawValue: error._code) {
                    switch errorCode  {
                    case .wrongPassword:
                        completion(.failure(.wrongPassword))
                    case .invalidCredential:
                        completion(.failure(.invalidCredential))
                    case .userNotFound:
                        completion(.failure(.userNotFound))
                    default:
                        completion(.failure(.generic))
                    }
                    print("There was an error logging in new user: \(error.localizedDescription)")
                    return
                }
            }
            guard let authDataResult = authDataResult else { completion(.failure(.generic)) ; return }
            completion(.success(authDataResult.user))
        }
    }
    
    func getLoggedInUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func logOutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
