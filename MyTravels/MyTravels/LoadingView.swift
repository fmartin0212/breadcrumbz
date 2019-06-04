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
    @IBOutlet weak var loadingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blackView.layer.cornerRadius = 7
        blackView.layer.opacity = 0.5
        self.backgroundColor = nil
        viewOne.layer.cornerRadius = viewOne.frame.width / 2
        view2.layer.cornerRadius = view2.frame.width / 2
        view3.layer.cornerRadius = view3.frame.width / 2
        
        let keyFrameAnim = CAKeyframeAnimation(keyPath: "transform.scale.x")
        keyFrameAnim.values = [1, 1.5, 1]
        keyFrameAnim.keyTimes = [0, 0.5, 1]
        keyFrameAnim.duration = 1
        viewOne.layer.add(keyFrameAnim, forKey: "hi")
        
//        let keyFrameAnim2 = CAKeyframeAnimation(keyPath: "transform.scale.y")
//        keyFrameAnim2.values = [1.2, 1.5, 2]
//        keyFrameAnim2.keyTimes = [0, 0.5, 1]
//        keyFrameAnim2.duration = 1
//        viewOne.layer.add(keyFrameAnim2, forKey: "2")
        
        //        let cgAffineTran = CGAffineTransform(scaleX: 0.40, y: 0.40)
        //        UIView.animate(withDuration: 1) {
        //            self.viewOne.transform = cgAffineTran
        //            self.viewOne.transform = .identity
        //        }
        
        
//        let cgAffineTran = CGAffineTransform(scaleX: 0.40, y: 0.40)
//            UIView.animate(withDuration: 0.50, delay: 0, options: [], animations: {
//                self.viewOne.transform = cgAffineTran
//                self.viewOne.transform = .identity
//
//            }) { (success) in
//                UIView.animate(withDuration: 0.50, delay: 0, options: [], animations: {
//                    self.view2.transform = cgAffineTran
//                    self.view2.transform = .identity
//
//                }) { (success) in
//                    UIView.animate(withDuration: 0.50, delay: 0, options: [], animations: {
//                        self.view3.transform = cgAffineTran
//                        self.view3.transform = .identity
//
//                    }) { (success) in
//
//                    }
//                }
//            }
    }
    
    deinit {
        print("The loading view was deinitialized.")
    }
}
