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
    let extraData: ExtraCarData?
    
    let hasDisablity: Bool
    
    let isImport: Bool
    let isMotorcycle: Bool
    let isHeavy: Bool
    
    let numberOfVehiclesWithIdenticalModel: Int
    
    var sections: [CDParameterSection] {
        return [baseSection(), specSection(), motSection(), extraSection(), safetySection()].compactMap( { $0.parameters.count == 0 ? nil : $0 })
    }
    
    func baseSection() -> CDParameterSection {
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .manufacturer, value: extraData?.manufacturer ?? baseData.manufacturer))
        parameters.append(CDParameter(type: .model, value: baseData.model ?? baseData.modelNumber))
        parameters.append(CDParameter(type: .trimLevel, value: baseData.trimLevel))
        parameters.append(CDParameter(type: .modelYear, value: baseData.modelYear))
        parameters.append(CDParameter(type: .moedAliyaLakvish, value: baseData.moedAliyaLakvish))
        parameters.append(CDParameter(type: .color, value: baseData.color))
        
        if isImport {
            parameters.append(CDParameter(type: .importType, value: baseData.importType))
        }
        
        parameters = parameters.compactMap( { ($0.value == nil || $0.value as? String == "") ? nil : $0 })
        
        return CDParameterSection(title: "פרטים בסיסיים", parameters: parameters)
        
    }
    
    func specSection() -> CDParameterSection {
        var parameters: [CDParameter] = []
        
        if isMotorcycle,
           let motoDisplacement = baseData.motoDisplacement {
            parameters.append(CDParameter(type: .displacement, value: Int(motoDisplacement)))
        } else {
            parameters.append(CDParameter(type: .displacement, value: extraData?.displacement))
        }
        
        parameters.append(CDParameter(type: .isAutomatic, value: extraData?.isAutomatic?.booleanValue()))
        parameters.append(CDParameter(type: .wheelDrive, value: extraData?.wheelDrive))
        parameters.append(CDParameter(type: .fuelType, value: baseData.fuelType))
        parameters.append(CDParameter(type: .horsepower, value: extraData?.horsepower ?? baseData.motoHorsePower))
        parameters.append(CDParameter(type: .curbWeight, value: extraData?.curbWeight))
        parameters.append(CDParameter(type: .rearTireSize, value: baseData.rearTireSize))
        parameters.append(CDParameter(type: .frontTireSize, value: baseData.frontTireSize))
        
        parameters = parameters.compactMap( { ($0.value == nil || $0.value as? String == "") ? nil : $0 })
        
        return CDParameterSection(title: "נתונים טכניים", parameters: parameters)
    }
    
    func motSection() -> CDParameterSection {
        
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .lastMOT, value: baseData.lastMOT?.asDateFormat(inputFormat: .govApiFormat, outputFormat: .uiFormat)))
        parameters.append(CDParameter(type: .registrationGroup, value: extraData?.registrationGroup))
        parameters.append(CDParameter(type: .nextMOT, value: baseData.nextMOT?.asDateFormat(inputFormat: .govApiFormat, outputFormat: .uiFormat)))
        parameters.append(CDParameter(type: .ownership, value: baseData.ownership))
        parameters.append(CDParameter(type: .chassis, value: baseData.chassis))
        parameters.append(CDParameter(type: .horaatRishum, value: baseData.horaatRishum))
        
        parameters.append(CDParameter(type: .totalLossDate, value: baseData.totalLossDate?.asDateFormat(inputFormat: .govApiFormat, outputFormat: .uiFormat)))
        
        parameters = parameters.compactMap( { ($0.value == nil || $0.value as? String == "") ? nil : $0 })
        
        return CDParameterSection(title: "פרטי רישוי", parameters: parameters)
    }
    
    func extraSection() -> CDParameterSection {
        
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .bodyType, value: extraData?.bodyType))
        parameters.append(CDParameter(type: .manufacturerCountry, value: extraData?.manufacturerCountry))
        parameters.append(CDParameter(type: .market, value: extraData?.market))
        parameters.append(CDParameter(type: .engineModel, value: baseData.engineModel))
        
        if numberOfVehiclesWithIdenticalModel > 0  {
            parameters.append(CDParameter(type: .numberOfIdenticalVehicles, value: numberOfVehiclesWithIdenticalModel))
        }

        parameters.append(CDParameter(type: .doorCount, value: extraData?.doorCount))
        parameters.append(CDParameter(type: .seatNumber, value: extraData?.seatNumber))
        parameters.append(CDParameter(type: .windows, value: extraData?.windows))
        parameters.append(CDParameter(type: .ac, value: extraData?.ac?.booleanValue()))
        parameters.append(CDParameter(type: .sunroof, value: extraData?.sunroof?.booleanValue()))
        parameters.append(CDParameter(type: .hasAlloys, value: extraData?.hasAlloys?.booleanValue()))
        parameters.append(CDParameter(type: .towingCapacity, value: extraData?.towingCapacity))
        parameters.append(CDParameter(type: .towingCapacityNoBrakes, value: extraData?.towingCapacityNoBrakes))
        parameters.append(CDParameter(type: .catalyticConverter, value: extraData?.catalyticConverter))
        
        parameters = parameters.compactMap( { ($0.value == nil || $0.value as? String == "") ? nil : $0 })
        
        return CDParameterSection(title: "פרטים נוספים", parameters: parameters)
    }
    
    func safetySection() -> CDParameterSection {
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .safetyScore, value: extraData?.safetyScore))
        parameters.append(CDParameter(type: .airbags, value: extraData?.airbags))
        parameters.append(CDParameter(type: .abs, value: extraData?.abs?.booleanValue()))
        parameters.append(CDParameter(type: .tcs, value: extraData?.tcs?.booleanValue()))
        parameters.append(CDParameter(type: .frontDistanceMonitor, value: extraData?.frontDistanceMonitor?.booleanValue()))
        parameters.append(CDParameter(type: .adaptiveCruiseControl, value: extraData?.adaptiveCruiseControl?.booleanValue()))
        parameters.append(CDParameter(type: .blintspotMonitor, value: extraData?.blintspotMonitor?.booleanValue()))
        parameters.append(CDParameter(type: .pedestrianMonitor, value: extraData?.pedestrianMonitor?.booleanValue()))
        parameters.append(CDParameter(type: .aebs, value: extraData?.aebs?.booleanValue()))
        parameters.append(CDParameter(type: .reversingCamera, value: extraData?.reversingCamera?.booleanValue()))
        parameters.append(CDParameter(type: .tpms, value: extraData?.tpms?.booleanValue()))
        parameters.append(CDParameter(type: .safetyBeltSensors, value: extraData?.safetyBeltSensors?.booleanValue()))
        parameters.append(CDParameter(type: .automaticHeadlights, value: extraData?.automaticHeadlights?.booleanValue()))
        parameters.append(CDParameter(type: .automaticHighBeams, value: extraData?.automaticHighBeams?.booleanValue()))
        parameters.append(CDParameter(type: .trafficSignMonitor, value: extraData?.trafficSignMonitor?.booleanValue()))
        parameters.append(CDParameter(type: .motorcycleMonitor, value: extraData?.motorcycleMonitor?.booleanValue()))
        
        if isImport || isHeavy || isMotorcycle {
            parameters = parameters.compactMap( { ($0.value == nil || $0.value as? String == "") ? nil : $0 })
        }
        
        return CDParameterSection(title: "בטיחות", parameters: parameters)
    }
    
}
