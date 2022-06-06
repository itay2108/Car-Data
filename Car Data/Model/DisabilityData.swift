//
//  DisabilityData.swift
//  Car Data
//
//  Created by itay gervash on 05/06/2022.
//

import Foundation

struct DisabilityDataRespone: Codable {
    let success: Bool
    let result: DisabilityDataResult
}

struct DisabilityDataResult: Codable {
    let records: [DisabilityData]
}

struct DisabilityData: Codable {
    let id, plateNumber, issueDate, disabilityType: Int
    let rank: Double

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case plateNumber = "MISPAR RECHEV"
        case issueDate = "TAARICH HAFAKAT TAG"
        case disabilityType = "SUG TAV"
        case rank
    }
}
