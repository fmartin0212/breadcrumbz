//
//  CoreDataStack.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 1/30/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStack {
    
    // Init the stack with persistent container
    static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyTravels")
        // Load what's in the persistent store
        container.loadPersistentStores(completionHandler: { (storedDescription, error) in
            if let error = error {
                fatalError()
            }
        })
        return container
    }()
    
    static var context : NSManagedObjectContext { return container.viewContext }
    
}


