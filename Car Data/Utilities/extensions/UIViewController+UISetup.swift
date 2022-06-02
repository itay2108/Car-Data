//
//  UIViewController+UISetup.swift
//  Car Data
//
//  Created by itay gervash on 31/05/2022.
//

import UIKit

extension UIViewController {
    
    ///When inheriting from CDViewController this method gets called in viewDidLoad(_ animated:)
    @objc func setupUI() {
        setupViews()
        setupConstraints()
    }
    
    ///Gets Called In setupUI()
    @objc func setupViews() { }
    
    @objc func setupConstraints() { }
    
}
