//
//  GenericScrollingLabelViewController.swift
//  MyTravels
//
//  Created by Frank Martin on 5/28/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

enum LegalInfo {
    case privacyPolicy
    case termsOfService
}

class GenericScrollingLabelViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var genericLabel: UILabel!
    let legalInfo: LegalInfo
    
    init(legalInfo: LegalInfo, nibName: String) {
        self.legalInfo = legalInfo
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()

    }
}

extension GenericScrollingLabelViewController {
    
    func updateViews() {
        switch legalInfo {
        case .privacyPolicy:
            genericLabel.text = Constants.privacyPolicy
            title = "Privacy Policy"
        case .termsOfService:
            genericLabel.text = Constants.termsAndConditions
            title = "Terms of Service"
        }
    }
}
