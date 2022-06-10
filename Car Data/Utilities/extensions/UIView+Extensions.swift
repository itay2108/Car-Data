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
    
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
