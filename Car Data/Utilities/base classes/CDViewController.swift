//
//  CDViewController.swift
//  Car Data
//
//  Created by itay gervash on 31/05/2022.
//

import UIKit
import Hero

class CDViewController: UIViewController {
    
    var licensePlateNumber: String?
    
    var heroNavigationControllerDelegateCache: UINavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        hero.isEnabled = true
        hero.modalAnimationType = .push(direction: .left)
    }
    
}
