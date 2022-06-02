//
//  LoadResultViewController.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit
import NVActivityIndicatorView

class LoadResultViewController: CDViewController {

    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var licensePlateLabel: UILabel!
    
    @IBOutlet weak var lodingLabel: UILabel!
    
    var licensePlateNumber: String?
    
    let licensePlateManager = LicensePlateManager()
    
    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            //push
        }
        
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupActivityIndicator()
        setupLicensePlateLabel()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func setupLicensePlateLabel() {
        guard let licensePlateNumber = licensePlateNumber else {
            licensePlateLabel.text = ""
            return
        }
        
        licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(licensePlateNumber)
    }
    
    //MARK: - Data Methods
    
    

}
