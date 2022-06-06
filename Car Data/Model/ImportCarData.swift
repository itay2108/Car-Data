//
//  ImportCarData.swift
//  Car Data
//
//  Created by itay gervash on 06/06/2022.
//

import Foundation

// MARK: - ImportCarData
struct ImportCarDataResponse: Codable {
    let success: Bool
    let result: ImportCarDataResult
}

// MARK: - Result
struct ImportCarDataResult: Codable {
    let records: [ImportCarData]
}

// MARK: - Record
struct ImportCarData: Codable {
    let id, plateNumber: Int?
    let chassis, manufacturerCode, manufacturer, modelClass: String?
    let modelNumber, curbWeight, modelYear: String?
    let displacement, manufacturerCountry, engineModel, lastMOT: String?
    let nextMOT, importType, moedAliyaLakvish, fuelType: String?
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case plateNumber = "mispar_rechev"
        case chassis = "shilda"
        case manufacturerCode = "tozeret_cd"
        case manufacturer = "tozeret_nm"
        case modelClass = "sug_rechev_nm"
        case modelNumber = "degem_nm"
        case curbWeight = "mishkal_kolel"
        case modelYear = "shnat_yitzur"
        case displacement = "nefach_manoa"
        case manufacturerCountry = "tozeret_eretz_nm"
        case engineModel = "degem_manoa"
        case lastMOT = "mivchan_acharon_dt"
        case nextMOT = "tokef_dt"
        case importType = "sug_yevu"
        case moedAliyaLakvish = "moed_aliya_lakvish"
        case fuelType = "sug_delek_nm"
        case rank
    }
}
