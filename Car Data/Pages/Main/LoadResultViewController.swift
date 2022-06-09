//
//  LoadResultViewController.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

protocol LoadResultDelegate {
    func resultLoader(didReceive data: CarData)
    func resultLoader(didFailWith error: Error, for licensePlate: String?)
}

extension LoadResultDelegate {
    func resultLoader(didReceive data: CarData) { }
    func resultLoader(didFailWith error: Error, for licensePlate: String?) { }
}

class LoadResultViewController: CDViewController {

    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var licensePlateLabel: UILabel!
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    var delegate: LoadResultDelegate?
    
    var requestTimer: Timer?
    
    override var licensePlateNumber: String? {
        didSet {
            if licensePlateNumber != nil {
                    getCarData()
            }
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //timer
        respondToLongLoadingTime(after: 6)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        requestTimer?.invalidate()
        requestTimer = nil
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
    
    private func presentDataVC(using carData: CarData) {
        
        guard self.isViewLoaded else { return }
        
        if let destination = K.storyBoards.dataStoryBoard.instantiateViewController(withIdentifier: K.viewControllerIDs.dataVC) as? DataViewController {
            
            destination.licensePlateNumber = licensePlateNumber
            destination.data = carData
            
            delegate?.resultLoader(didReceive: carData)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.navigationController?.pushViewController(destination, animated: true)
                
                self?.navigationController?.viewControllers.removeAll(where: { $0 == self })
            }
            
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        CDTaskMonitor.main.cancelAllTasks()
        
        navigationController?.popViewController(animated: true)
        delegate?.resultLoader(didFailWith: CDError.canceled, for: licensePlateNumber)
    }
    
    //MARK: - Data Methods
    
    private func getCarData() {
        CarDataManager().getCarData(from: licensePlateNumber).then { [weak self] data in
            self?.presentDataVC(using: data)
            
        }.catch { [weak self] error in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.resultLoader(didFailWith: error, for: self?.licensePlateNumber)
            }
            
        }.always { [weak self] in
            self?.requestTimer?.invalidate()
            self?.requestTimer = nil
        }
    }
    
    private func respondToLongLoadingTime(after timeInterval: TimeInterval) {
        
        requestTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(refreshUIForLongLoadingTime), userInfo: nil, repeats: false)
        
    }
    
    @objc func refreshUIForLongLoadingTime() {
        
        closeButton.isHidden = false
        closeButton.fadeIn()
        
        loadingLabel.fadeOut { [weak self] finish in
            self?.loadingLabel.text = "רק עוד כמה רגעים..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.loadingLabel.fadeIn()
            }
        }


    }

}
