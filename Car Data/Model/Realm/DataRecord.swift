//
//  SearchResult.swift
//  Car Data
//
//  Created by itay gervash on 22/06/2022.
//

import UIKit
import RealmSwift

class DataRecord: Object {
    @Persisted var data: RealmCarData? = RealmCarData()
    @Persisted var date: Date = Date()
    
    @Persisted var key: String? = nil
    
    override class func primaryKey() -> String? {
        return "key"
    }
}

class DataRecordPreview: Object {
    @Persisted var plateNumber: Int = -1
    
    @Persisted var manufacturer: String? = nil
    @Persisted var model: String? = nil
    @Persisted var modelYear: Int? = nil
    
    @Persisted var date: Date = Date()
    
    @Persisted var key: String? = nil
    
    override class func primaryKey() -> String? {
        return "key"
    }
    
    convenience init(from carData: CarData) {
        self.init()
        
        self.plateNumber = carData.baseData.plateNumber
        
        self.manufacturer = carData.baseData.manufacturer ?? carData.extraData?.manufacturer
        self.model = carData.baseData.model ?? carData.baseData.modelNumber
        self.modelYear = carData.baseData.modelYear
    }
    
    func contains(_ value: String) -> Bool {
        
        let relevantParameters: [Any?] = [plateNumber, manufacturer, modelYear, model]
        
            for parameter in relevantParameters {
                if let parameterValue = parameter {
                    if String(describing: parameterValue).lowercased().contains(value.lowercased()) {
                        return true
                    }
                }
            }
        
        return false
    }
}
