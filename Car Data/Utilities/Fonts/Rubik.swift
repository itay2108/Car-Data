//
//  Rubik.swift
//  Car Data
//
//  Created by itay gervash on 31/05/2022.
//

import UIKit

enum Rubik: String {
    case light = "Rubik-Light"
    case regular = "Rubik-Regular"
    case medium = "Rubik-Medium"
    case semiBold = "Rubik-SemiBold"
    case bold = "Rubik-Bold"
    case extraBold = "Rubik-ExtraBold"
    case black = "Rubik-Black"
    
    func ofSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
