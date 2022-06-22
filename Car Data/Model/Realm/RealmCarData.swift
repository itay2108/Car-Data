//
//  RealmCarData.swift
//  Car Data
//
//  Created by itay gervash on 22/06/2022.
//

import Foundation
import RealmSwift

class RealmCarData: Object {
    @Persisted var id: Int = -1
    
    //Base Car Data
    
    @Persisted var plateNumber: Int? = nil
    @Persisted var manufacturerCode: Int? = nil
    @Persisted var modelClass: String? = nil
    @Persisted var manufacturer: String? = nil
    @Persisted var modelCode: Int? = nil
    @Persisted var modelNumber: String? = nil
    @Persisted var trimLevel: String? = nil
    @Persisted var pollutionLevel: Int? = nil
    @Persisted var modelYear: Int? = nil
    @Persisted var engineModel: String? = nil
    @Persisted var lastMOT: String? = nil
    @Persisted var nextMOT: String? = nil
    @Persisted var ownership: String? = nil
    @Persisted var chassis: String? = nil
    @Persisted var colorCode: Int? = nil
    @Persisted var color: String? = nil
    @Persisted var frontTireSize: String? = nil
    @Persisted var rearTireSize: String? = nil
    @Persisted var fuelType: String? = nil
    @Persisted var horaatRishum: Int? = nil
    @Persisted var moedAliyaLakvish: String? = nil
    @Persisted var model: String? = nil
    @Persisted var rank: Double? = nil
    
    @Persisted var importType: String? = nil
    
    @Persisted var motoHorsePower: Double? = nil
    @Persisted var motoDisplacement: Double? = nil
    @Persisted var totalLossDate: String? = nil
    
    
    //Extra Car Data
    
    @Persisted var extraModelClass: String? = nil
    @Persisted var extraManufacturerCode: Int? = nil
    @Persisted var manufacturerFull: String? = nil
    @Persisted var manufacturerCountry: String? = nil
    @Persisted var extraManufacturer: String? = nil
    @Persisted var extraModelCode: Int? = nil
    @Persisted var extraModelNumber: String? = nil
    @Persisted var extraModelYear: Int? = nil
    @Persisted var registrationGroup: Int? = nil
    @Persisted var displacement: Int? = nil
    @Persisted var curbWeight: Int? = nil
    @Persisted var height: Int? = nil
    @Persisted var wheelDriveCode: Int? = nil
    @Persisted var wheelDrive: String? = nil
    @Persisted var ac: Int? = nil
    @Persisted var abs: Int? = nil
    @Persisted var airbags: Int? = nil
    @Persisted var powerSteering: Int? = nil
    @Persisted var isAutomatic: Int? = nil
    @Persisted var windows: Int? = nil
    @Persisted var sunroof: Int? = nil
    @Persisted var hasAlloys: Int? = nil
    @Persisted var bodyType: String? = nil
    @Persisted var extraTrimLevel: String? = nil
    @Persisted var fuelCode: Int? = nil
    @Persisted var extraFuelType: String? = nil
    @Persisted var doorCount: Int? = nil
    @Persisted var horsepower: Int? = nil
    @Persisted var seatNumber: Int? = nil
    @Persisted var tcs: Int? = nil
    @Persisted var towingCapacity: Int? = nil
    @Persisted var towingCapacityNoBrakes: Int? = nil
    @Persisted var marketCode: Int? = nil
    @Persisted var market: String? = nil
    @Persisted var catalyticConverterCode: Int? = nil
    @Persisted var catalyticConverter: String? = nil
    @Persisted var wheelDriveTechnologyCode: String? = nil
    @Persisted var wheelDriveTechnology: String? = nil
    
    //        @Persisted var kamutCO2 = "kamut_CO2"
    //        @Persisted var kamutNOX = "kamut_NOX"
    //        @Persisted var kamutPM10 = "kamut_PM10"
    //        @Persisted var kamutHC = "kamut_HC"
    //        @Persisted var kamutHCNOX = "kamut_HC_NOX"
    //        @Persisted var kamutCO = "kamut_CO"
    //        @Persisted var kamutCO2City = "kamut_CO2_city"
    //        @Persisted var kamutNOXCity = "kamut_NOX_city"
    //        @Persisted var kamutPM10City = "kamut_PM10_city"
    //        @Persisted var kamutHCCity = "kamut_HC_city"
    //        @Persisted var kamutCOCity = "kamut_CO_city"
    //        @Persisted var kamutCO2Hway = "kamut_CO2_hway"
    //        @Persisted var kamutNOXHway = "kamut_NOX_hway"
    //        @Persisted var kamutPM10Hway = "kamut_PM10_hway"
    //        @Persisted var kamutHCHway = "kamut_HC_hway"
    //        @Persisted var kamutCOHway = "kamut_CO_hway"
    
    @Persisted var madadYarok: Int? = nil
    @Persisted var extraPollutionLevel: Int? = nil
    @Persisted var laneKeepAssist: Int? = nil
    @Persisted var frontDistanceMonitor: Int? = nil
    @Persisted var blintspotMonitor: Int? = nil
    @Persisted var adaptiveCruiseControl: Int? = nil
    @Persisted var pedestrianMonitor: Int? = nil
    @Persisted var emergencyBreakAssist: Int? = nil
    @Persisted var reversingCamera: Int? = nil
    @Persisted var tpms: Int? = nil
    @Persisted var safetyBeltSensors: Int? = nil
    @Persisted var safetyScore: Double? = nil
    @Persisted var safetyEquipmentScore: Int? = nil
    @Persisted var automaticHeadlights: Int? = nil
    @Persisted var automaticHighBeams: Int? = nil
    @Persisted var aebs: Int? = nil
    @Persisted var trafficSignMonitor: Int? = nil
    @Persisted var motorcycleMonitor: Int? = nil
    @Persisted var activeLaneKeepAssist: Int? = nil
    @Persisted var rearEmergencyBreakingSystem: Int? = nil
    @Persisted var bakaratMehirutISA: Int? = nil
    @Persisted var extraModel: String? = nil
    @Persisted var extraRank: Double? = nil
    
    //Miscellanious
    
    @Persisted var hasDisability: Bool = false
    @Persisted var isImport: Bool = false
    @Persisted var isMotorcycle: Bool = false
    @Persisted var isHeavy: Bool = false
    
    @Persisted var numberOfVehiclesWithIdenticalModel: Int = 0
    
    
    //Conversions
    
    func asCarData() -> CarData {
        
        let baseCarData = BaseCarData(from: self)
        let extraCarData = ExtraCarData(from: self)
        
        return CarData(id: self.id,
                       baseData: baseCarData,
                       extraData: extraCarData,
                       hasDisablity: self.hasDisability,
                       isImport: self.isImport,
                       isMotorcycle: self.isMotorcycle,
                       isHeavy: self.isHeavy,
                       numberOfVehiclesWithIdenticalModel: self.numberOfVehiclesWithIdenticalModel)
    }
    
    convenience init(from carData: CarData) {
        self.init()
        
        self.id = carData.id
        
        //Base Data
        self.plateNumber = carData.baseData.plateNumber
        self.manufacturerCode = carData.baseData.manufacturerCode
        self.modelClass = carData.baseData.modelClass
        self.manufacturer = carData.baseData.manufacturer
        self.modelCode = carData.baseData.modelCode
        self.modelNumber = carData.baseData.modelNumber
        self.trimLevel = carData.baseData.trimLevel
        self.pollutionLevel = carData.baseData.pollutionLevel
        self.modelYear = carData.baseData.modelYear
        self.engineModel = carData.baseData.engineModel
        self.lastMOT = carData.baseData.lastMOT
        self.nextMOT = carData.baseData.nextMOT
        self.ownership = carData.baseData.ownership
        self.chassis = carData.baseData.chassis
        self.colorCode = carData.baseData.colorCode
        self.color = carData.baseData.color
        self.frontTireSize = carData.baseData.frontTireSize
        self.rearTireSize = carData.baseData.rearTireSize
        self.fuelType = carData.baseData.fuelType
        self.horaatRishum = carData.baseData.horaatRishum
        self.moedAliyaLakvish = carData.baseData.moedAliyaLakvish
        self.model = carData.baseData.model
        self.rank = carData.baseData.rank
        
        self.importType = carData.baseData.importType
        self.motoHorsePower = carData.baseData.motoHorsePower
        self.motoDisplacement = carData.baseData.motoDisplacement
        self.totalLossDate = carData.baseData.totalLossDate
        
        //Extra Car Data
        
        self.extraModelClass = carData.extraData?.modelClass
        self.extraManufacturerCode = carData.extraData?.manufacturerCode
        self.manufacturerFull = carData.extraData?.manufacturerFull
        self.manufacturerCountry = carData.extraData?.manufacturerCountry
        self.extraManufacturer = carData.extraData?.manufacturer
        self.extraModelCode = carData.extraData?.modelCode
        self.extraModelNumber = carData.extraData?.modelNumber
        self.extraModelYear = carData.extraData?.modelYear
        self.registrationGroup = carData.extraData?.registrationGroup
        self.displacement = carData.extraData?.displacement
        self.curbWeight = carData.extraData?.curbWeight
        self.height = carData.extraData?.height
        self.wheelDriveCode = carData.extraData?.wheelDriveCode
        self.wheelDrive = carData.extraData?.wheelDrive
        self.ac = carData.extraData?.ac
        self.abs = carData.extraData?.abs
        self.airbags = carData.extraData?.airbags
        self.powerSteering = carData.extraData?.powerSteering
        self.isAutomatic = carData.extraData?.isAutomatic
        self.windows = carData.extraData?.windows
        self.sunroof = carData.extraData?.sunroof
        self.hasAlloys = carData.extraData?.hasAlloys
        self.bodyType = carData.extraData?.bodyType
        self.extraTrimLevel = carData.extraData?.trimLevel
        self.fuelCode = carData.extraData?.fuelCode
        self.extraFuelType = carData.extraData?.fuelType
        self.doorCount = carData.extraData?.doorCount
        self.horsepower = carData.extraData?.horsepower
        self.seatNumber = carData.extraData?.seatNumber
        self.tcs = carData.extraData?.tcs
        self.towingCapacity = carData.extraData?.towingCapacity
        self.towingCapacityNoBrakes = carData.extraData?.towingCapacityNoBrakes
        self.marketCode = carData.extraData?.marketCode
        self.market = carData.extraData?.market
        self.catalyticConverterCode = carData.extraData?.catalyticConverterCode
        self.catalyticConverter = carData.extraData?.catalyticConverter
        self.wheelDriveTechnologyCode = carData.extraData?.wheelDriveTechnologyCode
        self.wheelDriveTechnology = carData.extraData?.wheelDriveTechnology
        
        //        @Persisted var kamutCO2 = "kamut_CO2"
        //        @Persisted var kamutNOX = "kamut_NOX"
        //        @Persisted var kamutPM10 = "kamut_PM10"
        //        @Persisted var kamutHC = "kamut_HC"
        //        @Persisted var kamutHCNOX = "kamut_HC_NOX"
        //        @Persisted var kamutCO = "kamut_CO"
        //        @Persisted var kamutCO2City = "kamut_CO2_city"
        //        @Persisted var kamutNOXCity = "kamut_NOX_city"
        //        @Persisted var kamutPM10City = "kamut_PM10_city"
        //        @Persisted var kamutHCCity = "kamut_HC_city"
        //        @Persisted var kamutCOCity = "kamut_CO_city"
        //        @Persisted var kamutCO2Hway = "kamut_CO2_hway"
        //        @Persisted var kamutNOXHway = "kamut_NOX_hway"
        //        @Persisted var kamutPM10Hway = "kamut_PM10_hway"
        //        @Persisted var kamutHCHway = "kamut_HC_hway"
        //        @Persisted var kamutCOHway = "kamut_CO_hway"
        
        self.madadYarok = carData.extraData?.madadYarok
        self.extraPollutionLevel = carData.extraData?.pollutionLevel
        self.laneKeepAssist = carData.extraData?.laneKeepAssist
        self.frontDistanceMonitor = carData.extraData?.frontDistanceMonitor
        self.blintspotMonitor = carData.extraData?.blintspotMonitor
        self.adaptiveCruiseControl = carData.extraData?.adaptiveCruiseControl
        self.pedestrianMonitor = carData.extraData?.pedestrianMonitor
        self.emergencyBreakAssist = carData.extraData?.emergencyBreakAssist
        self.reversingCamera = carData.extraData?.reversingCamera
        self.tpms = carData.extraData?.tpms
        self.safetyBeltSensors = carData.extraData?.safetyBeltSensors
        self.safetyScore = carData.extraData?.safetyScore
        self.safetyEquipmentScore = carData.extraData?.safetyEquipmentScore
        self.automaticHeadlights = carData.extraData?.automaticHeadlights
        self.automaticHighBeams = carData.extraData?.automaticHighBeams
        self.aebs = carData.extraData?.aebs
        self.trafficSignMonitor = carData.extraData?.trafficSignMonitor
        self.motorcycleMonitor = carData.extraData?.motorcycleMonitor
        self.activeLaneKeepAssist = carData.extraData?.activeLaneKeepAssist
        self.rearEmergencyBreakingSystem = carData.extraData?.rearEmergencyBreakingSystem
        self.bakaratMehirutISA = carData.extraData?.bakaratMehirutISA
        self.extraModel = carData.extraData?.model
        self.extraRank = carData.extraData?.rank
        
        //Miscellanious
        
        self.hasDisability = carData.hasDisablity
        self.isImport = carData.isImport
        self.isMotorcycle = carData.isMotorcycle
        self.isHeavy = carData.isHeavy
        
        self.numberOfVehiclesWithIdenticalModel = carData.numberOfVehiclesWithIdenticalModel
    }
    
}
