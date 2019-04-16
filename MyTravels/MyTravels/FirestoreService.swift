//
//  FirebaseService.swift
//  MyTravels
//
//  Created by Frank Martin on 4/13/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirestoreServiceProtocol {
    func save<T: FirestoreSavable>(object: T, completion: @escaping(Result<String, FireError>) -> Void)
    func update<T: FirestoreSavable>(object: T, atField field: String, withCriteria criteria: [String], with updateType: FirestoreUpdateType, completion: @escaping (Result<Bool, FireError>) -> Void)
    func delete<T: FirestoreSavable>(object: T, completion: @escaping (Result<Bool, FireError>) -> Void)
    func fetch<T: FirestoreRetrievable>(uuid: String?, field: String?, criteria: String?, queryType: FirestoreQueryType?, completion: @escaping (Result<[T], FireError>) -> Void)
}

protocol FirestoreSyncable {
    var uuid: String? { get set }
    static var collectionReference: CollectionReference { get }
    static var collectionName: String { get set }
}

extension FirestoreSyncable {
    static var collectionReference: CollectionReference {
        return Firestore.firestore().collection(Self.collectionName)
    }
}

protocol FirestoreRetrievable: FirestoreSyncable {
    init?(dictionary: [String : Any], uuid: String)
}

protocol FirestoreSavable: FirestoreSyncable {
    var dictionary: [String : Any] { get }
}

enum FirestoreQueryType {
    case fieldEqual
    case fieldArrayContains
}

enum FirestoreUpdateType {
    case update
    case arrayAddtion
    case arrayDeletion
}
public struct FirestoreService: FirestoreServiceProtocol {
    
    func save<T: FirestoreSavable>(object: T,
                                   completion: @escaping(Result<String, FireError>) -> Void) {
        var docRef: DocumentReference?
        if let uuid = object.uuid {
            docRef = T.collectionReference.document(uuid)
        } else {
            docRef = T.collectionReference.document()            
        }
        docRef?.setData(object.dictionary) { (error) in
            if let error = error {
                print("Error saving to Firestore: \(error.localizedDescription)")
                completion(.failure(.deleting))
                return
            }
            completion(.success(docRef!.documentID))
        }
    }
    
    func update<T: FirestoreSavable>(object: T,
                                     atField field: String,
                                     withCriteria criteria: [String],
                                     with updateType: FirestoreUpdateType,
                                     completion: @escaping (Result<Bool, FireError>) -> Void) {
        guard let uuid = object.uuid,
            criteria.count > 0,
            let singleCriteria = criteria.first
            else { completion(.failure(.generic)) ; return }
        let docRef = T.collectionReference.document(uuid)
        switch updateType {
            
        case .update:
            docRef.updateData([field : singleCriteria]) { (error) in
                if let error = error {
                    print("Error updating to Firestore: \(error.localizedDescription)")
                    completion(.failure(.updating))
                    return
                }
                completion(.success(true))
            }
            
        case .arrayAddtion:
            docRef.updateData([field : FieldValue.arrayUnion(criteria)]) { (error) in
                if let error = error {
                    print("Error updating to Firestore: \(error.localizedDescription)")
                    completion(.failure(.updating))
                    return
                }
                completion(.success(true))
            }
            
        case .arrayDeletion:
            docRef.updateData([field : FieldValue.arrayRemove(criteria)]) { (error) in
                if let error = error {
                    print("Error updating to Firestore: \(error.localizedDescription)")
                    completion(.failure(.updating))
                    return
                }
                completion(.success(true))
            }
        }
    }
    
    func delete<T: FirestoreSavable>(object: T,
                                     completion: @escaping (Result<Bool, FireError>) -> Void) {
        guard let uuid = object.uuid else { completion(.failure(.generic)) ; return }
        T.collectionReference.document(uuid).delete { (error) in
            if let error = error {
                print("Error deleting from Firestore: \(error.localizedDescription)")
                completion(.failure(.deleting))
                return
            }
            completion(.success(true))
        }
    }
    
    func fetch<T: FirestoreRetrievable>(uuid: String?,
                                        field: String?,
                                        criteria: String?,
                                        queryType: FirestoreQueryType?,
                                        completion: @escaping (Result<[T], FireError>) -> Void) {
        if let uuid = uuid {
            T.collectionReference.document(uuid).getDocument { (snapshot, error) in
                if let error = error {
                    print("Error fetching object from Firestore: \(error.localizedDescription)")
                    completion(.failure(.fetchingFromStore))
                    return
                }
                guard let snapshot = snapshot,
                    snapshot.exists,
                    let dictionary = snapshot.data(),
                    let object = T(dictionary: dictionary, uuid: snapshot.documentID)
                    else { completion(.failure(.fetchingFromStore)) ; return }
                completion(.success([object]))
                return
            }
        }
        
        guard let field = field,
            let criteria = criteria,
            let queryType = queryType
            else { completion(.failure(.fetchingFromStore)) ; return }
        
        let query: Query
        switch queryType {
        case .fieldEqual:
            query = T.collectionReference.whereField(field, isEqualTo: criteria)
        case .fieldArrayContains:
            query = T.collectionReference.whereField(field, arrayContains: criteria)
        }
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching objects from Firestore: \(error.localizedDescription)")
                completion(.failure(.fetchingFromStore))
                return
            }
            guard let snapshot = snapshot,
            snapshot.documents.count > 0
                else { completion(.failure(.fetchingFromStore)) ; return }
            let objects = snapshot.documents.compactMap { T(dictionary: $0.data(), uuid: $0.documentID) }
            completion(.success(objects))
        }
    }
}

