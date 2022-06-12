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
                                    getnumberOfVehiclesWithIdenticalModel(from: baseData)
                                    
                                        .then { numberOfIdenticalVehicles in
                                            
                                            fulfill(CarData(id: licensePlateAsInt,
                                                            baseData: baseData,
                                                            extraData: extraData,
                                                            hasDisablity: hasDisability,
                                                            isImport: false,
                                                            isMotorcycle: false,
                                                            isHeavy: false,
                                                            numberOfVehiclesWithIdenticalModel: numberOfIdenticalVehicles))
                                        }
                                }
                        }
                }
                //base data does hold alternative databases, but some vehicle categories don't contain extra data and get handled here:
                .catch { error in
                    
                    if let error = (error as? CDError),
                       error == CDError.notFound {
                        //import data
                        getImportCarData(from: licensePlateNumber)
                        
                            .then(on: DispatchQueue.global()) { importData in
                                getDisabilityData(from: licensePlateNumber)
                                
                                    .then { hasDisability in
                                        
                                        fulfill(CarData(id: licensePlateAsInt,
                                                        baseData: BaseCarData(importData),
                                                        extraData: nil,
                                                        hasDisablity: hasDisability,
                                                        isImport: true,
                                                        isMotorcycle: false,
                                                        isHeavy: false,
                                                        numberOfVehiclesWithIdenticalModel: 0))
                                    }
                            }
                            .catch { error in
                                //motorcycle data
                                
                                if let error = (error as? CDError),
                                   error == CDError.notFound {
                                    
                                    getMotoCarData(from: licensePlateNumber)
                                    
                                        .then(on: DispatchQueue.global()) { data in
                                            getDisabilityData(from: licensePlateNumber)
                                            
                                                .then { hasDisability in
                                                    getnumberOfVehiclesWithIdenticalModel(from: data, isMotorcycle: true)
                                                        
                                                        .then { identicalVehicles in
                                                            
                                                            fulfill(CarData(id: licensePlateAsInt,
                                                                            baseData: data,
                                                                            extraData: nil,
                                                                            hasDisablity: hasDisability,
                                                                            isImport: false,
                                                                            isMotorcycle: true,
                                                                            isHeavy: false,
                                                                            numberOfVehiclesWithIdenticalModel: identicalVehicles))
                                                        }.catch { error in
                                                            reject(error)
                                                        }

                                                }.catch { error in
                                                    reject(error)
                                                }
                                        }
                                        .catch { error in
                                            //heavy (bus & trailer) data
                                            
                                            if let error = (error as? CDError),
                                               error == CDError.notFound {
                                                
                                                getHeavyCarData(from: licensePlateNumber)
                                                
                                                    .then(on: DispatchQueue.global()) { data in
                                                        let baseData = BaseCarData(data)
                                                        getDisabilityData(from: licensePlateNumber)
                                                        
                                                            .then { hasDisability in
                                                                getnumberOfVehiclesWithIdenticalModel(from: baseData, isHeavy: true)
                                                                    
                                                                    .then { identicalVehicles in
                                                                    
                                                                    fulfill(CarData(id: licensePlateAsInt,
                                                                                    baseData: BaseCarData(data),
                                                                                    extraData: nil,
                                                                                    hasDisablity: hasDisability,
                                                                                    isImport: false,
                                                                                    isMotorcycle: true,
                                                                                    isHeavy: true,
                                                                                    numberOfVehiclesWithIdenticalModel: identicalVehicles))
                                                                    }.catch { error in
                                                                        reject(error)
                                                                    }
                                                            }.catch { error in
                                                                reject(error)
                                                            }
                                                    }
                                                    .catch { error in
                                                        reject(error)
                                                    }
                                            }
                                        }
                                } else {
                                    reject(error)
                                }
                            }
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
                
                //if available from basic database -
                if let plateNumber = Int(licensePlateNumber),
                   let result = data.result.records.first(where: { $0.plateNumber == plateNumber }) {
                    
                    fulfill(result)
                    
                    //else if not available but plate number is valid, try to get from inactive vehicles database -
                } else if let plateNumber = Int(licensePlateNumber),
                          let inactiveURL = urlManager.url(from: K.URLs.inactiveData, query: licensePlateNumber) {
                    
                    HTTPRequest.get(from: inactiveURL, decodeWith: BaseCarDataRespone.self).then(on: DispatchQueue.global()) { data in
                        if let result = data.result.records.first(where: { $0.plateNumber == plateNumber }) {
                            fulfill(result)
                            
                            //else if not available but plate number is valid, try to get from totaled vehicles database -
                        } else if let plateNumber = Int(licensePlateNumber),
                                  let totaledURL = urlManager.url(from: K.URLs.totaledData, query: licensePlateNumber) {
                            
                            HTTPRequest.get(from: totaledURL, decodeWith: TotaledCarDataRespone.self).then(on: DispatchQueue.global()) { data in
                                if let result = data.result.records.first(where: { $0.misparRechev == plateNumber }) {
                                    fulfill(BaseCarData(result))
                                    
                                    //else reject promise
                                } else if let plateNumber = Int(licensePlateNumber),
                                          let totaledURL = urlManager.url(from: K.URLs.totaledData, query: licensePlateNumber) {
                                    
                                    HTTPRequest.get(from: totaledURL, decodeWith: TotaledCarDataRespone.self).then(on: DispatchQueue.global()) { data in
                                        if let result = data.result.records.first(where: { $0.misparRechev == plateNumber }) {
                                            fulfill(BaseCarData(result))
                                            
                                            //else reject promise
                                        } else {
                                            reject(CDError.notFound)
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
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
    
    private func getMotoCarData(from licensePlateNumber: String) -> Promise<BaseCarData> {
        
        return Promise { fulfill, reject in
            
            let url = urlManager.url(from: K.URLs.motoData, query: licensePlateNumber)
            
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
    
    private func getHeavyCarData(from licensePlateNumber: String) -> Promise<HeavyCarData> {
        
        return Promise { fulfill, reject in
            
            let url = urlManager.url(from: K.URLs.heavyData, query: licensePlateNumber)
            
            HTTPRequest.get(from: url, decodeWith: HeavyCarDataRespone.self).then(on: DispatchQueue.global()) { data in
                
                guard data.success else {
                    reject(CDError.requestError)
                    return
                }
                
                guard let plateNumber = Int(licensePlateNumber),
                      let result = data.result.records.first(where: { $0.misparRechev == plateNumber }) else {
                    
                    reject(CDError.notFound)
                    return
                }
                
                fulfill(result)
                
            }.catch { error in
                reject(error)
            }
        }
        
    }
    
    private func getExtraCarData(from baseData: BaseCarData) -> Promise<ExtraCarData?> {
        
        return Promise { fulfill, reject in
            
            guard let modelCode = baseData.modelCode,
                  let modelNumber = baseData.modelNumber else {
                fulfill(nil)
                return
            }
            
            let queries = [String(modelCode), modelNumber]
            
            let url = urlManager.url(from: K.URLs.extraData, queries: queries)
            
            HTTPRequest.get(from: url, decodeWith: ExtraCarDataRespone.self).then(on: DispatchQueue.global())  { data in
                
                guard data.success else {
                    fulfill(nil)
                    return
                }
                
                guard let result = data.result.records.first else {
                    
                    fulfill(nil)
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
                fulfill(false)
            }
        }
        
    }
    
    private func getnumberOfVehiclesWithIdenticalModel(from baseData: BaseCarData, isMotorcycle: Bool = false, isHeavy: Bool = false) -> Promise<Int> {
        
        return Promise { fulfill, reject in
            
            guard let manufacturerCode = baseData.manufacturerCode,
                  let modelNumber = baseData.modelNumber else {
                fulfill(0)
                return
            }
            
            var queries = [String(manufacturerCode), modelNumber]
            
            if let trimLevel = baseData.trimLevel {
                queries.append(trimLevel)
            }
            
            if let modelCode = baseData.modelCode {
                queries.append(String(modelCode))
            }
            
            if !isMotorcycle && !isHeavy {
                let url = urlManager.url(from: K.URLs.basicData, queries: queries, limit: 9999)
                
                HTTPRequest.get(from: url, decodeWith: BaseCarDataRespone.self).then(on: DispatchQueue.global())  { data in
                    
                    fulfill(data.result.records.count)
                }.catch { error in
                    fulfill(0)
                }
            } else if isMotorcycle {
                
                let url = urlManager.url(from: K.URLs.motoData, queries: queries, limit: 9999)
                
                HTTPRequest.get(from: url, decodeWith: BaseCarDataRespone.self).then(on: DispatchQueue.global())  { data in
                    
                    fulfill(data.result.records.count)
                }.catch { error in
                    fulfill(0)
                }
                
            } else if isHeavy {
                let url = urlManager.url(from: K.URLs.heavyData, queries: queries, limit: 9999)
                
                HTTPRequest.get(from: url, decodeWith: HeavyCarDataRespone.self).then(on: DispatchQueue.global())  { data in
                    
                    fulfill(data.result.records.count)
                }.catch { error in
                    fulfill(0)
                }
            } else {
                fulfill(0)
            }
            
        }
        
    }
    
}
