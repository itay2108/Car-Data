//
//  K.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit

struct K {
    
    struct colors {
        
        static let background = UIColor(named: "cd-background") ?? .white
        
        struct accents {
            static let yellow = UIColor(named: "AccentColor") ?? .yellow
            
            static let dark = UIColor(named: "cd-accent-dark") ?? .blue
            
            static let light = UIColor(named: "cd-accent-light") ?? .lightGray
        }
        
        struct text {
            static let dark = UIColor(named: "cd-text-dark") ?? .darkGray
            
            static let light = UIColor(named: "cd-text-light") ?? .blue
        }

    }
    
    struct segues {
        struct mainStoryboard {
            static let mainToLoadResult = "mainToLoadResult"
        }
    }
}
