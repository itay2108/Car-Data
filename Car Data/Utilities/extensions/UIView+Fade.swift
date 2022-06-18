//
//  UIView+Fade.swift
//  Car Data
//
//  Created by itay gervash on 01/06/2022.
//

import UIKit

extension UIView {
    
    func fadeIn(duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, _ completion: (()->Void)? = nil) {
        self.isHidden = false
        self.alpha = 0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
    
    func fadeOut(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        
        self.alpha = 1
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
