//
//  CarDataManager.swift
//  Car Data
//
//  Created by itay gervash on 05/06/2022.
//

import Foundation
import Promises

struct CarDataManager {
    
    let urlManager = CDURLManager()
    
    func getCarData(from licensePlateNumber: String?) -> Promise<CarData> {
        
        return Promise { fulfill, reject in
            
            guard let licensePlateNumber = licensePlateNumber,
                  let licensePlateAsInt = Int(licensePlateNumber) else {
                reject(CDError.badData)
                return
            }
            
            getBaseCarData(from: licensePlateNumber)
            
                .then(on: DispatchQueue.global()) { baseData in
                    getExtraCarData(from: baseData)
                        .then { extraData in
                        getDisabilityData(from: licensePlateNumber)
                                .then { hasDisability in
                                    getnumberOfVehiclesWithIdenticalModel(from: baseData).then { numberOfIdenticalVehicles in
                                        fulfill(CarData(id: licensePlateAsInt, baseData: baseData, extraData: extraData, hasDisablity: hasDisability, isImport: false, numberOfVehiclesWithIdenticalModel: numberOfIdenticalVehicles))
                                    }
                        }
                    }
                }
                .catch { error in
                    
                    if let error = (error as? CDError),
                       error == CDError.notFound {
                        
                        getImportCarData(from: licensePlateNumber)
                        
                            .then(on: DispatchQueue.global()) { importData in
                                getDisabilityData(from: licensePlateNumber).then { hasDisability in
                                    fulfill(CarData(id: licensePlateAsInt, baseData: BaseCarData(importData), extraData: nil, hasDisablity: hasDisability, isImport: true, numberOfVehiclesWithIdenticalModel: 0))
                                }
                            }
                            .catch { error in
                                reject(error)
                            }
                    } else {
                        reject(error)
                    }
                }
            
        }
        
    }
    
    private func getBaseCarData(from licensePlateNumber: String) -> Promise<BaseCarData> {
        
        return Promise { fulfill, reject in
            
            let url = urlManager.url(from: K.URLs.basicData, query: licensePlateNumber)
            
            HTTPRequest.get(from: url, decodeWith: BaseCarDataRespone.self).then(on: DispatchQueue.global()) { data in
                
                guard data.success else {
                    reject(CDError.requestError)
                    return
                }
                
                guard let plateNumber = Int(licensePlateNumber),
                    let result = data.result.records.first(where: { $0.plateNumber == plateNumber }) else {
                    
                    reject(CDError.notFound)
                    return
                }
                
                fulfill(result)
                
            }.catch { error in
                reject(error)
            }
        }
        
        
    }
    
    private func getImportCarData(from licensePlateNumber: String) -> Promise<ImportCarData> {
        
        return Promise { fulfill, reject in
            
            let url = urlManager.url(from: K.URLs.basicImportData, query: licensePlateNumber)
            
            HTTPRequest.get(from: url, decodeWith: ImportCarDataResponse.self).then(on: DispatchQueue.global()) { data in
                
                guard data.success else {
                    reject(CDError.requestError)
                    return
                }
                
                guard let plateNumber = Int(licensePlateNumber),
                    let result = data.result.records.first(where: { $0.plateNumber == plateNumber }) else {
                    
                    reject(CDError.notFound)
                    return
                }
                
                fulfill(result)
                
            }.catch { error in
                reject(error)
            }
        }
        
        
    }
    
    private func getExtraCarData(from baseData: BaseCarData) -> Promise<ExtraCarData> {
        
        return Promise { fulfill, reject in
            
            guard let modelCode = baseData.modelCode,
                  let modelNumber = baseData.modelNumber else {
                reject(CDError.badData)
                return
            }
            
            let queries = [String(modelCode), modelNumber]
            
            let url = urlManager.url(from: K.URLs.extraData, queries: queries)
            
            HTTPRequest.get(from: url, decodeWith: ExtraCarDataRespone.self).then(on: DispatchQueue.global())  { data in
                
                guard data.success else {
                    reject(CDError.requestError)
                    return
                }
                
                guard let result = data.result.records.first else {
                    
                    reject(CDError.notFound)
                    return
                }
                
                fulfill(result)
                
            }.catch { error in
                reject(error)
            }
        }
    }
    
    private func getDisabilityData(from licensePlateNumber: String) -> Promise<Bool> {
        
        return Promise { fulfill, reject in
            
            let url = urlManager.url(from: K.URLs.diasabilityData, query: licensePlateNumber)
            
            HTTPRequest.get(from: url, decodeWith: DisabilityDataRespone.self).then(on: DispatchQueue.global())  { data in
                
                fulfill(data.result.records.count > 0)
            }.catch { error in
                reject(error)
            }
        }
        
    }
    
    private func getnumberOfVehiclesWithIdenticalModel(from baseData: BaseCarData) -> Promise<Int> {
        
        return Promise { fulfill, reject in
            
            guard let manufacturerCode = baseData.manufacturerCode,
                  let modelCode = baseData.modelCode,
                  let modelNumber = baseData.modelNumber,
                  let trimLevel = baseData.trimLevel else {
                reject(CDError.badData)
                return
            }
            
            let queries = [String(manufacturerCode), String(modelCode), modelNumber, trimLevel]
            
            let url = urlManager.url(from: K.URLs.basicData, queries: queries, limit: 9999)
            
            HTTPRequest.get(from: url, decodeWith: BaseCarDataRespone.self).then(on: DispatchQueue.global())  { data in
                
                fulfill(data.result.records.count)
            }.catch { error in
                reject(error)
            }
        }
        
    }
    
}
