//
//  ExplanationViewController.swift
//  MyTravels
//
//  Created by Frank Martin Jr on 3/13/18.
//  Copyright © 2018 Frank Martin Jr. All rights reserved.
//

import UIKit

class ExplanationViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var obImageView: UIImageView!
    @IBOutlet weak var largeBlurb: UILabel!
    @IBOutlet weak var smallBlurb: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Constants.viewWillAppearForVC, object: nil, userInfo: ["viewController": self])
    }
}
