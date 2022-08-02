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
    
    var longWaitTimer: Timer?
    var timeoutTimer: Timer?
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if licensePlateNumber != nil {
            getCarData()
            
            //timers
            respondToLongLoadingTime(after: 6)
            respondToTimeout(after: 18)
            
        } else {
            delegate?.resultLoader(didFailWith: CDError.noDataProvided, for: nil)
            navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        longWaitTimer?.invalidate()
        longWaitTimer = nil
        
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        
        activityIndicator.stopAnimating()
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupLicensePlateLabel()
    }
    
    private func setupLicensePlateLabel() {
        guard let licensePlateNumber = licensePlateNumber else {
            licensePlateLabel.text = ""
            return
        }
        
        licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(licensePlateNumber)
    }
    
    private func presentDataVC(using carData: CarData) {
        
        guard self.isViewLoaded else {
            return
        }
        
        //update total number of searches
        let numberOfSearches = UserDefaultsManager.main.numberOfSearches()
        UserDefaultsManager.main.setValue(numberOfSearches + 1, forKey: .numberOfSearches)
        
        if let destination = K.storyBoards.dataStoryBoard.instantiateViewController(withIdentifier: K.viewControllerIDs.dataVC) as? DataViewController {
            
            destination.licensePlateNumber = licensePlateNumber
            destination.data = carData
            
            destination.isPresentingNewSearch = true
            destination.shouldPresentAdOnAppear = RNG.probability(of: 0) //TBC (50-70%)
            
            delegate?.resultLoader(didReceive: carData)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
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
        
        print("getting data...")
        CarDataManager().getCarData(from: licensePlateNumber).then { [weak self] data in
            print("received data...")
            //present data
            self?.presentDataVC(using: data)
            
            //save to realm
            let recordDate = Date()
            let recordKey = String(describing: data.baseData.plateNumber) + "-" + String(describing: recordDate)
            
            let record = DataRecord()
            record.data = RealmCarData(from: data)
            record.date = recordDate
            record.key = recordKey
            
            let recordPreview = DataRecordPreview(from: data)
            recordPreview.date = recordDate
            recordPreview.key = recordKey
            
            do {
                try RealmManager.save(record: record)
                try RealmManager.save(record: recordPreview)
            } catch {
                print(error)
            }
            
        }.catch { [weak self] error in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) {
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.resultLoader(didFailWith: error, for: self?.licensePlateNumber)
            }
            
        }.always { [weak self] in
            self?.longWaitTimer?.invalidate()
            self?.longWaitTimer = nil
        }
    }
    
    private func respondToLongLoadingTime(after timeInterval: TimeInterval) {
        
        longWaitTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(refreshUIForLongLoadingTime), userInfo: nil, repeats: false)
        
    }
    
    private func respondToTimeout(after timeInterval: TimeInterval) {
        timeoutTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(dismissForTimeout), userInfo: nil, repeats: false)
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
    
    @objc func dismissForTimeout() {
        
        navigationController?.popViewController(animated: true)
        delegate?.resultLoader(didFailWith: CDError.timeout, for: licensePlateNumber)
    }

}
