//
//  CoreDataManager.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 5/14/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CoreData


final class CoreDataManager {
  
    static func save() {
        do {
            try CoreDataStack.context.save()
        } catch let error {
            print("Error saving Managed Object Context: \(error)")
        }
    }
    
    static func delete<T: NSManagedObject>(object: T) {
            object.managedObjectContext?.delete(object)
            save()
    }
}


