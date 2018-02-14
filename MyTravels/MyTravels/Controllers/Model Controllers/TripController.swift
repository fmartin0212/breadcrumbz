//
//  TripController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class TripController {
    
    // MARK: - Properties
    static var shared = TripController()
    var frc: NSFetchedResultsController<Trip> = {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    var trip: Trip?
    var trips: [Trip] = []
    
    // MARK: - CRUD Functions
    // Create
    func createTripWith(location: String, startDate: Date, endDate: Date) {
//        let ckRecordIDString = nil
        let trip = Trip(location: location, startDate: startDate, endDate: endDate)
        self.trip = trip
        saveToPersistentStore()
        
    }
    
    func saveTripToCloud(trip: Trip) {
        guard let record = CKRecord(trip: trip) else { return }
        CloudKitManager.shared.saveToCloudKit(ckRecord: record) { (success) in
            
        }
        
    }
    
    func delete(trip: Trip) {
        trip.managedObjectContext?.delete(trip)
        saveToPersistentStore()
    }
    
//
//    func deleteAll() {
//        let moc = CoreDataStack.context
//
//        for place in TripController.shared.frc.fetchedObjects! {
//            moc.delete(place)
//        }
//
//        saveToPersistentStore()
//
//    }
    
    // Save to Core Data
    func saveToPersistentStore() {
        do {
            try CoreDataStack.context.save()
        } catch let error {
            print("Error saving Managed Object Context (Place): \(error)")
        }
    }
    

}

