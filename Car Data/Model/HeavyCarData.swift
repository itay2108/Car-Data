//
//  HeavyCarData.swift
//  Car Data
//
//  Created by itay gervash on 12/06/2022.
//

import Foundation


struct HeavyCarDataRespone: Codable {
    let success: Bool
    let result: HeavyCarDataResult
}

struct HeavyCarDataResult: Codable {
    let records: [HeavyCarData]
}

struct HeavyCarData: Codable {
    
    let id: Int?
    let misparRechev: Int
    let misparShilda, tkinaEU: String?
    let shnatYitzur, tozeretCD: Int?
    let tozeretNm, tozeretEretzNm: String?
    let sugDelekCD: Int?
    let sugDelekNm: String?
    let mishkalKolel, mishkalAzmi: Int?
    let degemNm: String?
    let nefachManoa: Int?
    let degemManoa, hanaaCD, hanaaNm: String?
    let mishkalMitanHarama: Int?
    let moedAliyaLakvish: String?
    let horaatRishum, misparMekomotLeydNahag, misparMekomot: Int?
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case misparRechev = "mispar_rechev"
        case misparShilda = "mispar_shilda"
        case tkinaEU = "tkina_EU"
        case shnatYitzur = "shnat_yitzur"
        case tozeretCD = "tozeret_cd"
        case tozeretNm = "tozeret_nm"
        case tozeretEretzNm = "tozeret_eretz_nm"
        case sugDelekCD = "sug_delek_cd"
        case sugDelekNm = "sug_delek_nm"
        case mishkalKolel = "mishkal_kolel"
        case mishkalAzmi = "mishkal_azmi"
        case degemNm = "degem_nm"
        case nefachManoa = "nefach_manoa"
        case degemManoa = "degem_manoa"
        case hanaaCD = "hanaa_cd"
        case hanaaNm = "hanaa_nm"
        case mishkalMitanHarama = "mishkal_mitan_harama"
        case moedAliyaLakvish = "moed_aliya_lakvish"
        case horaatRishum = "horaat_rishum"
        case misparMekomotLeydNahag = "mispar_mekomot_leyd_nahag"
        case misparMekomot = "mispar_mekomot"
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
