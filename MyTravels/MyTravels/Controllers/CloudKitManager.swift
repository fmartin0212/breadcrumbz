//
//  CloudKitManager.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager {
    
    static var shared = CloudKitManager()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // CRUD Functions
    // Add
    func saveToCloudKit(ckRecord: CKRecord, completion: @escaping (Bool) -> Void) {
        
        publicDB.save(ckRecord) { (record, error) in
            if let error = error {
                print("There was an error saving to the database: \(error)")
            }
                
            else {
                print("Save successful!")
                completion(true)
                
            }
        }
        
    }
    
    func performFullSync(completion: @escaping (Bool) -> Void) {
        
        pushTripsToCloudKit(type: "Trip") { (success) in
            
        }
        pushPlacesToCloudKit { (success) in
            
        }
        completion(true)
    }
    
    func fetchAllUsers(completion: @escaping ([String]) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "User", predicate: predicate)
        
        CloudKitManager.shared.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            var usernames = [String]()
            guard let records = records else { completion([]) ; return }
            for record in records {
                guard let user = User(ckRecord: record) else { completion([]) ; return }
                usernames.append(user.username)
            }
           completion(usernames)
        }
    }
    
    
    func pushTripsToCloudKit(type: String, completion: @escaping (Bool) -> Void) {
        
        let unsyncedTripRecords = unsyncedRecordsOf(type: "Trip") as? [Trip] ?? []
        if unsyncedTripRecords.count > 0 {
            var allRecordsToSave = [[CKRecord]]()
            var tripRecordsToSave = [CKRecord]()
            var placeRecordsToSave = [CKRecord]()
            var tripPhotoArray = [CKRecord]()
            var placePhotos = [CKRecord]()
            
            for unsyncedTripRecord in unsyncedTripRecords {
                
                guard let newTripRecord = CKRecord(trip: unsyncedTripRecord) else { completion(false) ; return }
                tripRecordsToSave.append(newTripRecord)
                unsyncedTripRecord.cloudKitRecordIDString = newTripRecord.recordID.recordName
                TripController.shared.saveToPersistentStore()
                
                guard let places = unsyncedTripRecord.places?.allObjects as? [Place] else { continue }
                for place in places {
                    let newPlaceRecord = CKRecord(place: place, trip: unsyncedTripRecord)
                    placeRecordsToSave.append(newPlaceRecord)
                    place.cloudKitRecordIDString = newPlaceRecord.recordID.recordName
                    PlaceController.shared.saveToPersistentStore()
                    
                    guard let photos = place.photos?.allObjects as? [Photo] else { continue }
                    for photo in photos {
                        let newPlacePhotoRecord = CKRecord(photo: photo, place: place)
                        placePhotos.append(newPlacePhotoRecord)
                        photo.cloudKitRecordIDString = newPlacePhotoRecord.recordID.recordName
                    }
                }
                
                guard let tripPhoto = unsyncedTripRecord.photo else { continue }
                let newTripPhotoRecord = CKRecord(photo: tripPhoto, trip: unsyncedTripRecord)
                tripPhotoArray.append(newTripPhotoRecord)
                tripPhoto.cloudKitRecordIDString = newTripPhotoRecord.recordID.recordName
            }
            
            allRecordsToSave.append(tripRecordsToSave)
            allRecordsToSave.append(placeRecordsToSave)
            allRecordsToSave.append(tripPhotoArray)
            allRecordsToSave.append(placePhotos)
            
            for recordArray in allRecordsToSave {
                if recordArray.count > 0 {
                    saveOperation(records: recordArray) { (success) in
                        print("save operation success")
                        completion(true)
                    }
                }
            }
            
        }
        
    }
    
    func pushPlacesToCloudKit(completion: @escaping (Bool) -> Void) {
        
        let trips = TripController.shared.trips
        var newPlacesToSave = [CKRecord]()
        var placePhotos = [CKRecord]()
        for trip in trips {
            guard let places = trip.places?.allObjects as? [Place] else { completion(false) ; return }
            for place in places {
                if place.cloudKitRecordID == nil {
                    let newPlaceRecord = CKRecord(place: place, trip: trip)
                    newPlacesToSave.append(newPlaceRecord)
                    place.cloudKitRecordIDString = newPlaceRecord.recordID.recordName
                    PlaceController.shared.saveToPersistentStore()
                    
                    guard let photos = place.photos?.allObjects as? [Photo] else { continue }
                    for photo in photos {
                        let newPlacePhotoRecord = CKRecord(photo: photo, place: place)
                        placePhotos.append(newPlacePhotoRecord)
                        photo.cloudKitRecordIDString = newPlacePhotoRecord.recordID.recordName
                    }
                }
            }
            
            if newPlacesToSave.count > 0 {
                CloudKitManager.shared.saveOperation(records: newPlacesToSave, completion: { (success) in
                    print("New places successfully saved to existing trip(s)!")
                })
            }
        }
        completion(true)
    }
    
    //
    //    func fetchNewRecordsOf(type: String, completion: @escaping (Bool) -> Void) {
    //
    //
    //
    //    }
    
    // MARK: - Helper Fetches
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Trip":
            guard let trips = TripController.shared.frc.fetchedObjects else { return [] }
            return trips.flatMap { $0 as CloudKitSyncable }
        case "Place":
            guard let places = TripController.shared.frc.fetchedObjects else { return [] }
            return places.flatMap { $0 as CloudKitSyncable }
        case "Photo":
            guard let photos = PlaceController.shared.frc.fetchedObjects else { return [] }
            return photos.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func syncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { !$0.isSynced }
    }
    
    func saveOperation(records: [CKRecord], completion: @escaping (Bool) -> Void) {
    let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyOperation.perRecordCompletionBlock = nil
        modifyOperation.savePolicy = .allKeys
        modifyOperation.queuePriority = .high
        modifyOperation.qualityOfService = .userInteractive
        publicDB.add(modifyOperation)
        completion(true)
    }
    
    func updateOperation(records: [CKRecord], completion: @escaping (Bool) -> Void) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modifyOperation.perRecordCompletionBlock = nil
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.queuePriority = .high
        modifyOperation.qualityOfService = .userInteractive
        publicDB.add(modifyOperation)
        completion(true)
    }
    
    
    // Sharing
    func fetchTripShareReceiverWith(username: String, completion: @escaping (User?) -> Void) {
        let predicate = NSPredicate(format: "username == %@", username)
        let query = CKQuery(recordType: "User", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching 'Share Receiver' User. Error: \(error)")
                completion(nil)
                return
            }
            guard let records = records,
                let userRecord = records.first,
                let user = User(ckRecord: userRecord)
                else { completion(nil) ; return }
            print("adsf")
            completion(user)
            
        }
    }
    
    func shareTripWith(user: User, trip: Trip, completion: @escaping (Bool) -> Void) {
        
        
        guard let tripReference = trip.cloudKitReference else { completion(false) ; return }
        user.sharedWithUserTripsRefs?.append(tripReference)
        guard let updatedUserRecord = CKRecord(user: user) else { completion(false) ; return }
        let recordToBeSaved = [updatedUserRecord]
        updateOperation(records: recordToBeSaved) { (success) in
            print("user successfully updated")
            completion(true)
        }
    }
    
    func fetchTripsSharedWithUser(completion: @escaping ([Trip]) -> Void) {
        guard let loggedInUser = UserController.shared.loggedInUser,
        let loggedInUserCKRecord = loggedInUser.ckRecordID?.recordName
        else { completion([]) ; return }
        var trips = [Trip]()
        
        let predicate = NSPredicate(format: "userIDsTripSharedWith == %@", loggedInUserCKRecord)
        let query = CKQuery(recordType: "Trip", predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                ("Error fetching trips shared with user. Error: \(error)")
            }
            
            guard let records = records else { completion([]) ; return }
            for record in records {
                guard let trip = Trip(record: record, context: CoreDataStack.context) else { completion([]) ; return }
                print(trip.location)
                trips.append(trip)
            }
        }
        completion(trips)
    }
}
