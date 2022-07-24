//
//  PremiumDisplayable.swift
//  Car Data
//
//  Created by itay gervash on 24/07/2022.
//

import UIKit

protocol PremiumDisplayable: UIViewController {
    func prepareForPremiumDisplay()
    func premiumDidDisplay()
}

extension PremiumDisplayable {
    
    var hasPremium: Bool {
        return UserDefaultsManager.main.value(forKey: .hasPremium) as? Bool ?? false
    }
    
    func showPremiumViewController() {
        guard !hasPremium else {
            return
        }
        
        prepareForPremiumDisplay()
        
        let destination = PremiumViewController()
        
        if let nc = self.navigationController {
            nc.heroNavigationAnimationType = .cover(direction: .up)
            
            nc.pushViewController(destination, animated: true)
            premiumDidDisplay()
            
        } else {
            present(destination, animated: true) { [weak self] in
                self?.premiumDidDisplay()
            }
        }
    }
    
    func prepareForPremiumDisplay() { }
    func premiumDidDisplay() { }
}
