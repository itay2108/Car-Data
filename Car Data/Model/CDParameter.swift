//
//  Parameter.swift
//  Car Data
//
//  Created by itay gervash on 04/06/2022.
//

import Foundation

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
    
}
