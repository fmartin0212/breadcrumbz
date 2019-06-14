//
//  LoadingView.swift
//  
//
//  Created by Frank Martin Jr on 12/12/18.
//

import UIKit
//import Cor

final class LoadingView: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var blackView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blackView.layer.cornerRadius = 7
        blackView.layer.opacity = 0.3
        self.backgroundColor = nil
        viewOne.layer.cornerRadius = viewOne.frame.width / 2
        view2.layer.cornerRadius = view2.frame.width / 2
        view3.layer.cornerRadius = view3.frame.width / 2
        
        let cgAffineTran = CGAffineTransform(scaleX: 1.5, y: 1.5)
        UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [.repeat], animations: {
           
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1667, animations: {
                self.viewOne.transform = cgAffineTran
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.1667, relativeDuration: 0.1667, animations: {
                self.viewOne.transform = .identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.3333, relativeDuration: 0.1667, animations: {
                self.view2.transform = cgAffineTran
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1667, animations: {
                self.view2.transform = .identity
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.6667, relativeDuration: 0.1667, animations: {
                self.view3.transform = cgAffineTran
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.8334, relativeDuration: 0.1667, animations: {
                self.view3.transform = .identity
            })
        }, completion: nil)
    }
    
    deinit {
        print("The loading view was deinitialized.")
    }
}
