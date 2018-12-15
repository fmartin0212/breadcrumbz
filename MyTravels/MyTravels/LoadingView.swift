//
//  LoadingView.swift
//  
//
//  Created by Frank Martin Jr on 12/12/18.
//

import UIKit

class LoadingView: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        blackView.layer.cornerRadius = 7
        blackView.layer.opacity = 0.5
        
        self.backgroundColor = nil
    }
    
    deinit {
        print("The loading view was deinitialized.")
    }
}
