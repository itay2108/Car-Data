//
//  CarData.swift
//  Car Data
//
//  Created by itay gervash on 05/06/2022.
//

import Foundation


struct CarData {
    
    let id: Int
    
    let baseData: BaseCarData
    let extraData: ExtraCarData
    
    let hasDisablity: Bool
    
    
    func topSection() -> [CDParameter] {
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .manufacturer, value: baseData.manufacturer))
        parameters.append(CDParameter(type: .model, value: baseData.model))
        parameters.append(CDParameter(type: .trimLevel, value: baseData.trimLevel))
        parameters.append(CDParameter(type: .modelYear, value: baseData.modelYear))
        parameters.append(CDParameter(type: .moedAliyaLakvish, value: baseData.moedAliyaLakvish))
        parameters.append(CDParameter(type: .color, value: baseData.color))
        
        return parameters
        
    }
    
    func midSection() -> [CDParameter] {
        
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .manufacturer, value: baseData.manufacturer))
        parameters.append(CDParameter(type: .model, value: baseData.model))
        parameters.append(CDParameter(type: .trimLevel, value: baseData.trimLevel))
        parameters.append(CDParameter(type: .modelYear, value: baseData.modelYear))
        parameters.append(CDParameter(type: .moedAliyaLakvish, value: baseData.moedAliyaLakvish))
        parameters.append(CDParameter(type: .color, value: baseData.color))
        
        return parameters
    }
    
}
