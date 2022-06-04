//
//  CarData.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import Foundation

struct BasicData: Codable {
    let success: Bool
    let result: BasicDataResult
}

struct BasicDataResult: Codable {
    let records: [CarData]
}

// MARK: - CarData

struct CarData: Codable {
    let id, plateNumber, manufacturerCode: Int?
    let modelClass, manufacturer: String?
    let modelCode: Int?
    let modelNumber, trimLevel: String?
    let pollutionLevel, modelYear: Int?
    let engineModel, lastMOT, nextMOT, ownership: String?
    let chassis: String?
    let colorCode: Int?
    let color, frontTireSize, rearTireSize, fuelType: String?
    let horaatRishum: Int?
    let moedAliyaLakvish, model: String?
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case plateNumber = "mispar_rechev"
        case manufacturerCode = "tozeret_cd"
        case modelClass = "sug_degem"
        case manufacturer = "tozeret_nm"
        case modelCode = "degem_cd"
        case modelNumber = "degem_nm"
        case trimLevel = "ramat_gimur"
        case pollutionLevel = "kvutzat_zihum"
        case modelYear = "shnat_yitzur"
        case engineModel = "degem_manoa"
        case lastMOT = "mivchan_acharon_dt"
        case nextMOT = "tokef_dt"
        case ownership
        case chassis = "misgeret"
        case colorCode = "tzeva_cd"
        case color = "tzeva_rechev"
        case frontTireSize = "zmig_kidmi"
        case rearTireSize = "zmig_ahori"
        case fuelType = "sug_delek_nm"
        case horaatRishum = "horaat_rishum"
        case moedAliyaLakvish = "moed_aliya_lakvish"
        case model = "kinuy_mishari"
        case rank
    }
    
    func topSection() -> [CDParameter] {
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .manufacturer, value: self.manufacturer))
        parameters.append(CDParameter(type: .model, value: self.model))
        parameters.append(CDParameter(type: .trimLevel, value: self.trimLevel))
        parameters.append(CDParameter(type: .modelYear, value: self.modelYear))
        parameters.append(CDParameter(type: .moedAliyaLakvish, value: self.moedAliyaLakvish))
        parameters.append(CDParameter(type: .color, value: self.color))
        
        return parameters
        
    }
    
    func midSection() -> [CDParameter] {
        
        var parameters: [CDParameter] = []
        
        parameters.append(CDParameter(type: .manufacturer, value: self.manufacturer))
        parameters.append(CDParameter(type: .model, value: self.model))
        parameters.append(CDParameter(type: .trimLevel, value: self.trimLevel))
        parameters.append(CDParameter(type: .modelYear, value: self.modelYear))
        parameters.append(CDParameter(type: .moedAliyaLakvish, value: self.moedAliyaLakvish))
        parameters.append(CDParameter(type: .color, value: self.color))
        
        return parameters
    }
}
