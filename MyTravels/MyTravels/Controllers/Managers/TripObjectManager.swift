//
//  TripObjectManager.swift
//  MyTravels
//
//  Created by Frank Martin on 5/15/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class TripObjectManager {
    
    func fetchTrips(for state: State, completion: @escaping (Result<[TripObject], Error>) -> Void) {
        if state == .shared {
            SharedTripsController.shared.fetchSharedTrips { [weak self] (result) in
                switch result {
                case .success(let sharedTrips):
                    completion(.success(sharedTrips))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            TripController.shared.fetchAllTrips()
            completion(.success(TripController.shared.trips))
        }
    }
    
    func fetchPhoto(for trip: TripObject, completion: @escaping (Result<UIImage, FireError>) -> Void) {
        if let sharedTrip = trip as? SharedTrip {
            if let photoUID = sharedTrip.photoUID {
                PhotoController.shared.fetchPhoto(withPath: photoUID) { (result) in
                    switch result {
                    case .success(let photo):
                        completion(.success(photo))
                    case .failure(_):
                        print("Something went wrong fetching a trip's photo")
                    }
                }
            } else {
                completion(.failure(.generic))
            }
        } else {
            let trip = trip as! Trip
            guard let photo = trip.photo else { completion(.failure(.generic)) ; return }
            completion(.success(photo.image))
        }
    }
}
