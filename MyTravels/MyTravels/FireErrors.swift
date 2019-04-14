//
//  FireErrors.swift
//  MyTravels
//
//  Created by Frank Martin on 4/14/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation

enum FireError: String, Error {
   
    // MARK: - Firestore
    
    case savingToStore = "fdffa"
    case updating = "fdffaa"
    case deleting = "fdfsfa"
    case generic = "fdssffa"
    case fetchingFromStore = "fdasaaffa"
    
    // MARK: - FirebaseStorage
    
    case savingToStorage = "There was an error saving your item. Please try again."
    case fetchingFromStorage
    // MARK: - FirebaseAuth
    
    case emailAlreadyInUse = "That email address is already in use. Please try again."
    case invalidEmail = "The email address that you entered is invalid. Please try again."
    case weakPassword = "That password is too short. Please enter a password that is at least 6 characters long."
    case wrongPassword = "The password that you entered was incorrect. Please try again."
    case invalidCredential = "Invalid email or password. Please try again."
    case userNotFound = "An account was not found for that email address. Please try again."
}
