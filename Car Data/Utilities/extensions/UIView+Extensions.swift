//
//  UIView+Extensions.swift
//  Car Data
//
//  Created by itay gervash on 06/06/2022.
//

import UIKit

public extension UIView {
    var heightModifier: CGFloat {
        get {
            return UIScreen.main.bounds.size.height / 812
        }
    }
    
    var widthModifier: CGFloat {
        get {
            return UIScreen.main.bounds.size.width / 375
        }
    }
}
