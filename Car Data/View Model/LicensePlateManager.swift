//
//  LicensePlateManager.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit

struct LicensePlateManager {
    
    static func maskToLicensePlateFormat(_ text: String) -> String {
        
        //license plate mask logic
        let numbers = text.filter { "0123456789".contains($0) }
        
        let cleanLicensePlate = numbers.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        var mask = ""
        
        switch numbers.count {
            
        case 1:
            mask = "#"
        case 2:
            mask = "##"
        case 3:
            mask = "##-#"
        case 4:
            mask = "##-##"
        case 5:
            mask = "##-###"
        case 6:
            mask = "###-###"
        case 7:
            mask = "##-###-##"
            
        default:
            mask = "###-##-###"
        }
        
        var result = ""
        var index = cleanLicensePlate.startIndex
        
        for ch in mask where index < cleanLicensePlate.endIndex {
            if ch == "#" {
                result.append(cleanLicensePlate[index])
                index = cleanLicensePlate.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        return result
        
        
    }
    
    static func licensePlateIsValid(_ input: String?) -> Bool {
        guard let rawText = input else {
            return false
        }
        
        let plateNumber = rawText.filter { "0123456789".contains($0) }
        
        if plateNumber.count < 5 || plateNumber.count > 8 || plateNumber.first == "0" {
            return false
        }
        
        return true
    }
    
    static func cleanLicensePlateNumber(from text: String) -> String {
        return text.filter { "0123456789".contains($0) }
    }
    
}
