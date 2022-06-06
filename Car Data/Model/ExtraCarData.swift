//
//  ExtraCarData.swift
//  Car Data
//
//  Created by itay gervash on 05/06/2022.
//

import Foundation

struct ExtraCarDataRespone: Codable {
    let success: Bool
    let result: ExtraCarDataResult
}

struct ExtraCarDataResult: Codable {
    let records: [ExtraCarData]
}

struct ExtraCarData: Codable {
    let id: Int?
    let modelClass: String?
    let manufacturerCode: Int?
    let manufacturerFull, manufacturerCountry, manufacturer: String?
    let modelCode: Int?
    let modelNumber: String?
    let modelYear, registrationGroup, displacement, curbWeight: Int?
    let height: Int?
    let wheelDriveCode: Int?
    let wheelDrive: String?
    let ac, abs: Int?
    let airbags, powerSteering, isAutomatic: Int?
    let windows, sunroof, hasAlloys: Int?
    let bodyType, trimLevel: String?
    let fuelCode: Int?
    let fuelType: String?
    let doorCount, horsepower, seatNumber, tcs: Int?
    let towingCapacity, towingCapacityNoBrakes, marketCode: Int?
    let market: String?
    let catalyticConverterCode: Int?
    let catalyticConverter, wheelDriveTechnologyCode, wheelDriveTechnology: String?
    
//    let kamutCO2: Int?
//    let kamutNOX, kamutPM10, kamutHC: Double?
//    let kamutHCNOX: Double?
//    let kamutCO: Double?
//    let kamutCO2City, kamutNOXCity, kamutPM10City, kamutHCCity: Double?
//    let kamutCOCity, kamutCO2Hway, kamutNOXHway, kamutPM10Hway: Double?
//    let kamutHCHway, kamutCOHway: Double?
    
    let madadYarok, pollutionLevel, laneKeepAssist: Int?
    let frontDistanceMonitor: Int?
    let blintspotMonitor, adaptiveCruiseControl, pedestrianMonitor: Int?
    let emergencyBreakAssist, reversingCamera, tpms, safetyBeltSensors: Int?
    let safetyScore: Double?
    let safetyEquipmentScore: Int?
    let automaticHeadlights, automaticHighBeams: Int?
    let aebs, trafficSignMonitor, motorcycleMonitor: Int?
    let activeLaneKeepAssist, rearEmergencyBreakingSystem, bakaratMehirutISA: Int?
    let model: String?
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case modelClass = "sug_degem"
        case manufacturerCode = "tozeret_cd"
        case manufacturerFull = "tozeret_nm"
        case manufacturerCountry = "tozeret_eretz_nm"
        case manufacturer = "tozar"
        case modelCode = "degem_cd"
        case modelNumber = "degem_nm"
        case modelYear = "shnat_yitzur"
        case registrationGroup = "kvuzat_agra_cd"
        case displacement = "nefah_manoa"
        case curbWeight = "mishkal_kolel"
        case height = "gova"
        case wheelDriveCode = "hanaa_cd"
        case wheelDrive = "hanaa_nm"
        case ac = "mazgan_ind"
        case abs = "abs_ind"
        case airbags = "mispar_kariot_avir"
        case powerSteering = "hege_koah_ind"
        case isAutomatic = "automatic_ind"
        case windows = "mispar_halonot_hashmal"
        case sunroof = "halon_bagg_ind"
        case hasAlloys = "galgaley_sagsoget_kala_ind"
        case bodyType = "merkav"
        case trimLevel = "ramat_gimur"
        case fuelCode = "delek_cd"
        case fuelType = "delek_nm"
        case doorCount = "mispar_dlatot"
        case horsepower = "koah_sus"
        case seatNumber = "mispar_moshavim"
        case tcs = "bakarat_yatzivut_ind"
        case towingCapacity = "kosher_grira_im_blamim"
        case towingCapacityNoBrakes = "kosher_grira_bli_blamim"
        case marketCode = "sug_tkina_cd"
        case market = "sug_tkina_nm"
        case catalyticConverterCode = "sug_mamir_cd"
        case catalyticConverter = "sug_mamir_nm"
        case wheelDriveTechnologyCode = "technologiat_hanaa_cd"
        case wheelDriveTechnology = "technologiat_hanaa_nm"
        
//        case kamutCO2 = "kamut_CO2"
//        case kamutNOX = "kamut_NOX"
//        case kamutPM10 = "kamut_PM10"
//        case kamutHC = "kamut_HC"
//        case kamutHCNOX = "kamut_HC_NOX"
//        case kamutCO = "kamut_CO"
//        case kamutCO2City = "kamut_CO2_city"
//        case kamutNOXCity = "kamut_NOX_city"
//        case kamutPM10City = "kamut_PM10_city"
//        case kamutHCCity = "kamut_HC_city"
//        case kamutCOCity = "kamut_CO_city"
//        case kamutCO2Hway = "kamut_CO2_hway"
//        case kamutNOXHway = "kamut_NOX_hway"
//        case kamutPM10Hway = "kamut_PM10_hway"
//        case kamutHCHway = "kamut_HC_hway"
//        case kamutCOHway = "kamut_CO_hway"
        
        case madadYarok = "madad_yarok"
        case pollutionLevel = "kvutzat_zihum"
        case laneKeepAssist = "bakarat_stiya_menativ_ind"
        case frontDistanceMonitor = "nitur_merhak_milfanim_ind"
        case blintspotMonitor = "zihuy_beshetah_nistar_ind"
        case adaptiveCruiseControl = "bakarat_shyut_adaptivit_ind"
        case pedestrianMonitor = "zihuy_holchey_regel_ind"
        case emergencyBreakAssist = "maarechet_ezer_labalam_ind"
        case reversingCamera = "matzlemat_reverse_ind"
        case tpms = "hayshaney_lahatz_avir_batzmigim_ind"
        case safetyBeltSensors = "hayshaney_hagorot_ind"
        case safetyScore = "nikud_betihut"
        case safetyEquipmentScore = "ramat_eivzur_betihuty"
        case automaticHeadlights = "teura_automatit_benesiya_kadima_ind"
        case automaticHighBeams = "shlita_automatit_beorot_gvohim_ind"
        case aebs = "zihuy_matzav_hitkarvut_mesukenet_ind"
        case trafficSignMonitor = "zihuy_tamrurey_tnua_ind"
        case motorcycleMonitor = "zihuy_rechev_do_galgali"
        case activeLaneKeepAssist = "bakarat_stiya_activ_s"
        case rearEmergencyBreakingSystem = "blima_otomatit_nesia_leahor"
        case bakaratMehirutISA = "bakarat_mehirut_isa"
        case model = "kinuy_mishari"
        case rank = "rank"
    }
}
