//
//  AdViewController.swift
//  Car Data
//
//  Created by itay gervash on 19/07/2022.
//

import UIKit

class AdViewController: CDViewController {

    @IBOutlet weak var dismissButton: UIButton!
    
    
    
    @IBOutlet weak var adContainer: UIView!
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupAdView()
    }
    
    private func setupAdView() {
        //
    }
    
    //MARK: - Selectors
    
    @objc private func allowDismiss() {
        dismissButton.isHidden = false
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss()
    }
}
