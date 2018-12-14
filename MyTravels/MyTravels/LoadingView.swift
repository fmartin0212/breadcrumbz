//
//  LoadingView.swift
//  
//
//  Created by Frank Martin Jr on 12/12/18.
//

import UIKit

class LoadingView: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var blackSquareView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        blackSquareView.layer.cornerRadius = 7
//        blackSquareView.layer.opacity =
        
//        self.backgroundColor = nil
    }
}
