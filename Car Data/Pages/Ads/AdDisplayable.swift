//
//  AdDisplayable.swift
//  Car Data
//
//  Created by itay gervash on 23/07/2022.
//

import UIKit
import Hero

protocol AdDisplayable: UIViewController {
    func prepareForAdDisplay()
    func adDidDisplay()
}

extension AdDisplayable {
    
    func showAdViewController() {
        prepareForAdDisplay()
        
        let destination = AdViewController()
        
        if let nc = self.navigationController {
            nc.heroNavigationAnimationType = .cover(direction: .up)
            
            nc.pushViewController(destination, animated: true)
            adDidDisplay()
            
        } else {
            present(destination, animated: true) { [weak self] in
                self?.adDidDisplay()
            }
        }
    }
    
    func prepareForAdDisplay() { }
    func adDidDisplay() { }
}
