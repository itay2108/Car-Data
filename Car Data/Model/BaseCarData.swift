//
//  CarData.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import Foundation

struct BaseCarDataRespone: Codable {
    let success: Bool
    let result: BaseCarDataResult
}

struct BaseCarDataResult: Codable {
    let records: [BaseCarData]
}

struct BaseCarData: Codable {
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
    
    //import data
    let importType: String?
    
    //motorcycle data
    let motoHorsePower: Double?
    let motoDisplacement: Double?
    
    let totalLossDate: String?

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
        
        case importType = "irrelevant"
        
        case motoHorsePower = "hespek"
        case motoDisplacement = "nefach_manoa"
        
        case totalLossDate = "bitul_dt"
    }
    
    init(_ importData: ImportCarData) {
        self.id = importData.id
        self.plateNumber = importData.plateNumber
        self.manufacturerCode = Int(importData.manufacturerCode ?? "0")
        self.modelClass = importData.modelClass
        self.manufacturer = importData.manufacturer
        self.modelCode = nil
        self.modelNumber = importData.modelNumber
        self.trimLevel = nil
        self.pollutionLevel = nil
        self.modelYear = Int(importData.modelYear ?? "0")
        self.engineModel = importData.engineModel
        self.lastMOT = importData.lastMOT
        self.nextMOT = importData.nextMOT
        self.ownership = nil
        self.chassis = importData.chassis
        self.colorCode = nil
        self.color = nil
        self.frontTireSize = nil
        self.rearTireSize = nil
        self.fuelType = importData.fuelType
        self.horaatRishum = nil
        self.moedAliyaLakvish = importData.moedAliyaLakvish
        self.model = nil
        self.rank = nil
        
        self.importType = importData.importType
        
        self.motoHorsePower = nil
        self.motoDisplacement = nil
        self.totalLossDate = nil
    }
    
    
    init(_ totaledData: TotaledCarData) {
        self.id = totaledData.id
        self.plateNumber = totaledData.misparRechev
        self.manufacturerCode = totaledData.tozeretCD
        self.modelClass = totaledData.sugRechevNm
        self.manufacturer = totaledData.tozeretNm
        self.modelCode = totaledData.degemCD
        self.modelNumber = totaledData.degemNm
        self.trimLevel = totaledData.ramatGimur
        self.pollutionLevel = totaledData.kvutzatZihum
        self.modelYear = totaledData.shnatYitzur
        self.engineModel = totaledData.degemManoa
        self.lastMOT = nil
        self.nextMOT = nil
        self.ownership = nil
        self.chassis = totaledData.misgeret
        self.colorCode = nil
        self.color = totaledData.tzevaRechev
        self.frontTireSize = totaledData.zmigAhori
        self.rearTireSize = totaledData.zmigKidmi
        self.fuelType = totaledData.sugDelekNm
        self.horaatRishum = totaledData.horaatRishum
        
        if let moedAliyaLakvish = totaledData.moedAliyaLakvish {
            self.moedAliyaLakvish = String(moedAliyaLakvish)
        } else {
            self.moedAliyaLakvish = nil
        }
        
        self.model = totaledData.kinuyMishari
        self.rank = totaledData.rank
        
        self.importType = nil
        
        self.motoHorsePower = nil
        self.motoDisplacement = nil
        self.totalLossDate = totaledData.bitulDt
    }
}
