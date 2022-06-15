//
//  CDPreferenceTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 15/06/2022.
//

import UIKit

class CDPreferenceTableViewCell: UITableViewCell {

    var type: CDPreference = .none
    
    @objc enum CDPreference: Int {
        
        case none = 0
        
        case sortData = 1
        case filterData = 2
        
        case visionRecognitionStyle = 3
        
        case restorePurchases = 4
        case appStoreReview = 5
        case reportAProblem = 6
        case resetData = 7
        
        case upgrade = 8
    }

}
