//
//  UIGestureRecognizer+Extensions.swift
//  Car Data
//
//  Created by itay gervash on 01/06/2022.
//

import UIKit

extension UIGestureRecognizer {
    func finishCurrentGesture() {
        isEnabled = false
        isEnabled = true
    }
}
