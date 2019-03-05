//
//  Constants.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 12/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class Constants {
    
    // MARK: - Notifications
    
    static public let sharedTripsReceivedNotif = Notification.Name("sharedTripsReceived")
    static public let profilePictureUpdatedNotif = Notification.Name("profilePictureUpdatedNotification")
    static public let refreshSharedTripsListNotif = Notification.Name("refreshSharedTripsListNotif")
    static public let userLoggedInNotif = Notification.Name("userLoggedInNotif")
    
    // MARK: - Error messages
    
    static public let wrongPassword = "The password that you entered was incorrect. Please try again."
    static public let noAccount = "An account was not found for that email address. Please try again."
    static public let somethingWentWrong = "Something went wrong. Please try again."
    static public let emailInUse = "That email address is already in use. Please try again."
    static public let invalidEmail = "The email address that you entered is invalid. Please try again."
    static public let weakPassword = "That password is too short. Please enter a password that is at least 6 characters long."
    
    // MARK: - Firebase references
    
    static public let databaseRef = Database.database().reference()
    static public let storageRef = Storage.storage().reference()
    
    // MARK: - Firebase child names
    
    static public let trip = "Trip"
    static public let place = "Place"
    static public let photo = "Photo"
    static public let user = "User"
    static public let places = "places"
    static public let photoID = "photoID"
    static public let photoURLs = "photoURLs"
    static public let sharedTripIDs = "sharedTripIDs"
    static public let participantTripIDs = "participantTripIDs"
    
    }
