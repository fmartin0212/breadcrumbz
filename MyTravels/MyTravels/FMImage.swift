//
//  FMImage.swift
//  MyTravels
//
//  Created by Frank Martin on 5/28/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

class FMImage: FirebaseStorageSavable {
    
    var image: UIImage
    var data: Data {
        guard let data = self.image.pngData() else { return Data() }
        return data
    }
    var uid: String {
        guard let loggedInUserUID = InternalUserController.shared.loggedInUser?.uuid else { return "" }
        return loggedInUserUID
    }
    
    init(image: UIImage) {
        self.image = image
    }
}
