//
//  EmptyTripStateView.swift
//  MyTravels
//
//  Created by Frank Martin on 3/22/19.
//  Copyright © 2019 Frank Martin Jr. All rights reserved.
//

import UIKit

protocol EmptyTripStateViewDelegate: class {
    func getStartedButtonTapped()
}

class EmptyTripStateView: UIView {

    // MARK: - Properties
    
    @IBOutlet var tripImageView: UIImageView!
    @IBOutlet var topLabel: UILabel!
    @IBOutlet var bottomLabel: UILabel!
    @IBOutlet weak var getStartedButton: FMButton!
    
    var state: State = .managed {
        didSet {
            updateViews()
        }
    }
    weak var delegate: EmptyTripStateViewDelegate?
    
    // MARK: - Actions
    
    @IBAction func buttonTapped(sender: UIButton) {
        delegate?.getStartedButtonTapped()
    }
    
    private func updateViews() {
        if state == .shared {
            tripImageView.image = UIImage(named: "airplane")
            topLabel.text = "You're not following any trips!"
            bottomLabel.text = "When someone shares a trip with you, you'll see it here."
            getStartedButton.isHidden = true
        }
    }
}
