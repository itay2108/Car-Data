//
//  Cell+ReuseIdentifier.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit

extension UITableViewCell {
    static var reuseID: String {
        return String(describing: Self.self)
    }
}

extension UICollectionViewCell {
    static var reuseID: String {
        return String(describing: Self.self)
    }
}
