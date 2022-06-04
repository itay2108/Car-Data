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
    func resultLoader(didFailWith error: Error)
}

extension LoadResultDelegate {
    func resultLoader(didReceive data: CarData) { }
    func resultLoader(didFailWith error: Error) { }
}

class LoadResultViewController: CDViewController {

    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBOutlet weak var licensePlateLabel: UILabel!
    
    @IBOutlet weak var lodingLabel: UILabel!
    
    var delegate: LoadResultDelegate?
    
    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getCarData()
        
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
    
    private func getCarData() {
        guard let licensePlate = licensePlateNumber else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.resultLoader(didFailWith: CDError.noDataProvided)
            }
            
           return
        }
        
        if let url = URL(string: "\(K.URL.basicData)&q=\(licensePlate)") {
            
            let request = AF.request(url).validate(statusCode: 200..<300)
            
            request.responseDecodable(of: BasicData.self) { [weak self] afResponse in
                do {
                    let response = try afResponse.result.get()
                    
                    guard response.success else {
                        throw CDError.parseError
                    }
                    
                    let records = response.result.records
                    
                    guard records.count > 0,
                          let carData = records.first(where: {$0.plateNumber == Int(licensePlate)}) else {
                        throw CDError.notFound
                    }
                    
                    
                    if let destination = K.storyBoards.dataStoryBoard.instantiateViewController(withIdentifier: K.viewControllerIDs.dataVC) as? DataViewController {
                        
                        destination.licensePlateNumber = self?.licensePlateNumber
                        destination.data = carData
                        
                        self?.delegate?.resultLoader(didReceive: carData)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.navigationController?.pushViewController(destination, animated: true)

                            self?.navigationController?.viewControllers.removeAll(where: { $0 == self })
                        }
                        
                    } else {
                        throw CDError.unknownError
                    }
        
                    
                } catch {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.navigationController?.popViewController(animated: true)
                        self?.delegate?.resultLoader(didFailWith: error)
                    }
                    
                }
            }
        }
    }

}
