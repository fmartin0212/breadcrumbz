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
    static public let viewWillAppearForVC = Notification.Name("userLoggedInNotif")
    
    // MARK: - Error messages
    
    static public let somethingWentWrong = "Something went wrong. Please try again."

    
    // MARK: - Firebase references
    
    static public let databaseRef = Database.database().reference()
    static public let storageRef = Storage.storage().reference()
    
    // MARK: - Firebase child names
    
    static public let trip = "Trip"
    static public let crumb = "Crumb"
    static public let photo = "Photo"
    static public let user = "User"
    static public let places = "places"
    static public let photoID = "photoID"
    static public let photoURLs = "photoURLs"
    static public let sharedTripIDs = "sharedTripIDs"
    static public let participantTripIDs = "tripsFollowingUIDs"
    
    }
