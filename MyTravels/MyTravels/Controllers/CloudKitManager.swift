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
    
    func performFullSync() {
        
        
        
    }
    
    func pushToCloudKit(type: String, completion: @escaping (Bool) -> Void) {
        
        let unsyncedTripRecords = unsyncedRecordsOf(type: "Trip") as? [Trip] ?? []
        if unsyncedTripRecords.count > 0 {
            var tripRecordsToSave = [CKRecord]()
            var placeRecordsToSave = [CKRecord]()
            for unsyncedTripRecord in unsyncedTripRecords {
                
                guard let record = CKRecord(trip: unsyncedTripRecord) else { completion(false) ; return }
                unsyncedTripRecord.cloudKitRecordIDString = record.recordID.recordName
                TripController.shared.saveToPersistentStore()
                tripRecordsToSave.append(record)
                
                guard let places = unsyncedTripRecord.places?.allObjects as? [Place] else { continue }
                for place in places {
                    let record = CKRecord(place: place, trip: unsyncedTripRecord)
                    placeRecordsToSave.append(record)
                }
            }
            
            saveOperation(records: tripRecordsToSave) { (success) in
                print("save operation success")
                completion(true)
            }
        }
        
    }
//
//    func fetchNewRecordsOf(type: String, completion: @escaping (Bool) -> Void) {
//
//
//
//    }
    func performCoreDataFetches(completion: @escaping (Bool) -> Void) {
        do {
            try TripController.shared.frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
        }
        do {
            try PlaceController.shared.frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
        }
        do {
            try PhotoController.shared.frc.performFetch()
        } catch {
            NSLog("Error starting fetched results controller")
        }
        completion(true)
    }
    
    // MARK: - Helper Fetches
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        performCoreDataFetches { (success) in
            switch type {
            case "Trip":
                guard let trips = TripController.shared.frc.fetchedObjects else { return [] }
                return trips.flatMap { $0 as CloudKitSyncable }
            case "Place":
                guard let places = PlaceController.shared.frc.fetchedObjects else { return [] }
                return places.flatMap { $0 as CloudKitSyncable }
            case "Photo":
                guard let places = PlaceController.shared.frc.fetchedObjects else { return [] }
                
            default:
                return []
            }
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
    
}
