//
//  TotaledCarData.swift
//  Car Data
//
//  Created by itay gervash on 12/06/2022.
//

import Foundation

struct TotaledCarDataRespone: Codable {
    let success: Bool
    let result: TotaledCarDataResult
}

struct TotaledCarDataResult: Codable {
    let records: [TotaledCarData]
}

struct TotaledCarData: Codable {
    let id, misparRechev, tozeretCD: Int?
    let tozeretNm: String?
    let degemCD: Int?
    let degemNm: String?
    let sugRechevCD: Int?
    let sugRechevNm: String?
    let moedAliyaLakvish: Int?
    let bitulDt, misgeret, tozarManoa, degemManoa: String?
    let misparManoa: String?
    let mishkalKolel: Int?
    let ramatGimur: String?
    let ramatEivzurBetihuty, kvutzatZihum, shnatYitzur: Int?
    let baalut, tzevaRechev, zmigKidmi, zmigAhori: String?
    let sugDelekNm: String?
    let horaatRishum: Int?
    let kinuyMishari: String?
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case misparRechev = "mispar_rechev"
        case tozeretCD = "tozeret_cd"
        case tozeretNm = "tozeret_nm"
        case degemCD = "degem_cd"
        case degemNm = "degem_nm"
        case sugRechevCD = "sug_rechev_cd"
        case sugRechevNm = "sug_rechev_nm"
        case moedAliyaLakvish = "moed_aliya_lakvish"
        case bitulDt = "bitul_dt"
        case misgeret
        case tozarManoa = "tozar_manoa"
        case degemManoa = "degem_manoa"
        case misparManoa = "mispar_manoa"
        case mishkalKolel = "mishkal_kolel"
        case ramatGimur = "ramat_gimur"
        case ramatEivzurBetihuty = "ramat_eivzur_betihuty"
        case kvutzatZihum = "kvutzat_zihum"
        case shnatYitzur = "shnat_yitzur"
        case baalut
        case tzevaRechev = "tzeva_rechev"
        case zmigKidmi = "zmig_kidmi"
        case zmigAhori = "zmig_ahori"
        case sugDelekNm = "sug_delek_nm"
        case horaatRishum = "horaat_rishum"
        case kinuyMishari = "kinuy_mishari"
        case rank
    }
    
}

//"_id": 8302,
//"mispar_rechev": 88180102,
//"tozeret_cd": 481,
//"tozeret_nm": "יונדאי קוריאה",
//"degem_cd": 308,
//"degem_nm": "K281H",
//"sug_rechev_cd": 112,
//"sug_rechev_nm": "פרטי נוסעים",
//"moed_aliya_lakvish": 2022,
//"bitul_dt": "2022-05-22T00:00:00",
//"misgeret": "KMHK281HFNU152516",
//"tozar_manoa": "יונדאי",
//"degem_manoa": "EM16",
//"mispar_manoa": "EM16N2M093CS",
//"mishkal_kolel": 2020,
//"ramat_gimur": "EV",
//"ramat_eivzur_betihuty": 7,
//"kvutzat_zihum": 0,
//"shnat_yitzur": 2022,
//"baalut": "פרטי",
//"tzeva_rechev": "שנהב לבן",
//"zmig_kidmi": "215/55R17",
//"zmig_ahori": "215/55R17",
//"sug_delek_nm": "חשמל",
//"horaat_rishum": 200006,
//"kinuy_mishari": "KONA",
//"rank": 0.0573088
