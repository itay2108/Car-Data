//
//  MileageData.swift
//  Car Data
//
//  Created by itay gervash on 26/06/2022.
//

import Foundation

struct MileageDataRespone: Codable {
    let success: Bool
    let result: MileageDataResult
}

struct MileageDataResult: Codable {
    let records: [MileageData]
}

struct MileageData: Codable {

    let id, misparRechev: Int
    let misparManoa: String?
    let lastKnownMileage, shinuiMivneInd, gapamInd, shnuiZevaInd: Int?
    let shinuiZmigInd: Int?
    let rishumRishonDt, mkoriutNm: String?
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case misparRechev = "mispar_rechev"
        case misparManoa = "mispar_manoa"
        case lastKnownMileage = "kilometer_test_aharon"
        case shinuiMivneInd = "shinui_mivne_ind"
        case gapamInd = "gapam_ind"
        case shnuiZevaInd = "shnui_zeva_ind"
        case shinuiZmigInd = "shinui_zmig_ind"
        case rishumRishonDt = "rishum_rishon_dt"
        case mkoriutNm = "mkoriut_nm"
        case rank
    }
    
}
