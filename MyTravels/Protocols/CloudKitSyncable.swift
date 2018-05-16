//
//  CloudKitSyncable.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

protocol CloudKitSyncable {
    
    init?(record: CKRecord, context: NSManagedObjectContext)
    
    // Needs to be in the data model file
    var cloudKitRecordIDString: String? { get set }
    
    // These are going to be outside the data model file
    var recordType: String { get }
    var cloudKitRecordID: CKRecordID? { get }
    var reference: CKReference? { get }
}
extension CloudKitSyncable {
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    
    var cloudKitReference: CKReference? {
        
        guard let recordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: recordID, action: .none)
    }
}
