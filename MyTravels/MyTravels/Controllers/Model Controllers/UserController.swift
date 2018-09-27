//
//  UserController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 2/9/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    static var shared = UserController()
    
    var loggedInUser: User?
    
    func createNewUserWith(firstName: String?, lastName: String?, username: String?, profilePicture: Data?, completion: @escaping (Bool) -> Void) {
        
    }
    
    func fetchCurrentUser(completion: @escaping (Bool) -> Void) {
       
    }
}
