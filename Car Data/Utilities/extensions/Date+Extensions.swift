//
//  Date+Extensions.swift
//  Car Data
//
//  Created by itay gervash on 07/06/2022.
//

import Foundation

extension Date {
    
    static var currentYear: Int? {
        return Int(Calendar.current.component(.year, from: Date()))
    }
    
    func isInThePast() -> Bool {
        return self < Date()
    }
    
    func asString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd-HH-mm-ss"
        
        return formatter.string(from: self)
    }
}
