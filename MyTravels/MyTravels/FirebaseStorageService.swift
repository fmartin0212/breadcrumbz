//
//  FirebaseStorageService.swift
//  MyTravels
//
//  Created by Frank Martin on 4/14/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import Foundation
import FirebaseStorage

protocol FirebaseStorageServiceProtocol {
    func save(data: Data, to storeRef: StorageReference, completion: @escaping (Result<String, FireError>) -> Void)
    func save<T: FirebaseStorageSavable>(_ object: T, completion: @escaping (Result<String, FireError>) -> Void)
    func fetchImage(storeRef: StorageReference, completion: @escaping (Result<UIImage, FireError>) -> Void)
    func fetchFromStorage(path: String, completion: @escaping (Result<Data, FireError>) -> Void)
}

public struct FirebaseStorageService: FirebaseStorageServiceProtocol  {
    
    func save(data: Data,
              to storeRef: StorageReference,
              completion: @escaping (Result<String, FireError>) -> Void) {
        
        storeRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.savingToStore))
                return
            }
            guard let _ = metadata else { completion(.failure(.generic)) ; return }
            completion(.success(storeRef.fullPath))
        }
    }
    
    func save<T: FirebaseStorageSavable>(_ object: T,
                                         completion: @escaping (Result<String, FireError>) -> Void) {
        let storageRef = Storage.storage().reference().child(object.uid)
        storageRef.putData(object.data, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(.savingToStorage))
                return
            }
            guard let _ = metadata else { completion(.failure(.generic)) ; return }
            completion(.success(storageRef.fullPath))
        }
    }
    
    func fetchImage(storeRef: StorageReference,
                    completion: @escaping (Result<UIImage, FireError>) -> Void) {
        
        storeRef.getData(maxSize: 9999999) { (data, error) in
            if let error = error {
                print("There was an error getting the image: \(error.localizedDescription)")
                completion(.failure(.fetchingFromStorage))
                return
            }
            guard let data = data,
                let image = UIImage(data: data)
                else { completion(.failure(.generic)) ; return }
            completion(.success(image))
        }
    }
    
    func fetchFromStorage(path: String,
                          completion: @escaping (Result<Data, FireError>) -> Void) {
        Storage.storage().reference(withPath: path).getData(maxSize: 9999) { (data, error) in
            if let error = error {
                print("There was an error getting the image: \(error.localizedDescription)")
                completion(.failure(.fetchingFromStorage))
                return
            }
            guard let data = data else { completion(.failure(.generic)) ; return }
            completion(.success(data))
        }
    }
}
