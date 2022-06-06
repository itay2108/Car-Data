//
//  Parameter.swift
//  Car Data
//
//  Created by itay gervash on 04/06/2022.
//

import Foundation

struct CDParameterSection {
    let title: String?
    let parameters: [CDParameter]
}

struct CDParameter {
    let type: CDParameterType
    let value: Any?
}

enum CDParameterType: String, CaseIterable {
    case id = "מספר מזהה"
    case plateNumber = "מספר רכב"
    case manufacturerCode = "קוד יצרן"
    case modelClass = "סוג דגם"
    case manufacturer = "יצרן"
    case modelCode = "קוד  דגם"
    case modelNumber = "מספר דגם"
    case trimLevel = "רמת גימור"
    case pollutionLevel = "קבוצת זיהום"
    case modelYear = "שנת יצור"
    case engineModel = "דגם מנוע"
    case lastMOT = "מבחן רישוי אחרון"
    case nextMOT = "תוקף רישוי"
    case ownership = "בעלות"
    case chassis = "מספר שלדה"
    case colorCode = "קוד צבע"
    case color = "צבע רכב"
    case frontTireSize = "צמיג קדמי"
    case rearTireSize = "צמיג אחורי"
    case fuelType = "סוג דלק"
    case horaatRishum = "הוראת רישום"
    case moedAliyaLakvish = "מועד עליה לכביש"
    case model = "דגם"
    case rank = "דירוג"
    
    

    case manufacturerCountry = "ארץ יצור"
    case registrationGroup = "קבוצת אגרה"
    case displacement = "נפח מנוע"
    case curbWeight = "משקל כולל"
    case height = "גובה"
    case wheelDriveCode = "קוד הנעה"
    case wheelDrive = "הנעה"
    case ac = "מיזוג אוויר"
    case abs = "מערכת ABS"
    case airbags = "מספר כריות אוויר"
    case powerSteering = "הגה כוח"
    case isAutomatic = "אוטמטי"
    case windows = "מספר חלונות חשמליים"
    case sunroof = "חלון בגג"
    case hasAlloys = "חישוקי סגסוגת קלה (מגנזיום)"
    case bodyType = "מרכב"
    case fuelCode = "קוד דלק"
    case doorCount = "מספר דלתות"
    case horsepower = "הספק (כוח סוס)"
    case seatNumber = "מספר מושבים"
    case tcs = "בקרת יציבות"
    case towingCapacity = "כושר גרירה (עם בלמים)"
    case towingCapacityNoBrakes = "כושר גרירה (בלי בלמים)"
    case marketCode = "קוד תקינה"
    case market = "תקינה"
    case catalyticConverterCode = "קוד ממיר"
    case catalyticConverter = "סוג ממיר"
    case wheelDriveTechnologyCode = "קוד טכנולוגיית הנעה"
    case wheelDriveTechnology = "טכנולוגיית הנעה"
    
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
    
    case madadYarok = "מדד ירוק"
    case laneKeepAssist = "בקרת סטייה מנתיב"
    case frontDistanceMonitor = "ניטור מרחק מלפנים"
    case blintspotMonitor = "ניטור שטחים מתים"
    case adaptiveCruiseControl = "בקרת שיוט אדפטיבית"
    case pedestrianMonitor = "זיהוי הולכי רגל"
    case emergencyBreakAssist = "מערכת עזר לבלמים"
    case reversingCamera = "מצלמת רוורס"
    case tpms = "חיישני לחץ אוויר בגלגלים"
    case safetyBeltSensors = "חיישני חגורות"
    case safetyScore = "ניקוד בטיחות"
    case safetyEquipmentScore = "רמת אבזור בטיחותי"
    case automaticHeadlights = "תאורה אוטומטית בנסיעה קדימה"
    case automaticHighBeams = "תאורה אוטומטית באורות גבוהים"
    case aebs = "זיהוי מצב התקרבות מסוכנת"
    case trafficSignMonitor = "זיהוי תמרורי תנועה"
    case motorcycleMonitor = "זיהוי רכב דו גלגלי"
    case activeLaneKeepAssist = "בקרת סטייה מנתיב (אקטיבית) "
    case rearEmergencyBreakingSystem = "בלימה אוטומטית בנסיעה לאחור"
    case bakaratMehirutISA = "בקרת מהירות"
    
    case importType = "סוג ייבוא"
    
}
