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
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func isInPastWeek() -> Bool {
        let dateComponents = Calendar.current.dateComponents([.day], from: self, to: Date())
        
        return (dateComponents.day ?? 7) < 7 && self.isInThePast()
    }
    
    func isInPastYear() -> Bool {
        let dateComponents = Calendar.current.dateComponents([.year], from: self, to: Date())
        
        return (dateComponents.year ?? 1) < 1 && self.isInThePast()
    }
    
    func formatted(to format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        
        return dateFormatter.string(from: self)
    }
    
    func hebrewWeekday() -> String {
        let weekday = Calendar.current.dateComponents([.weekday], from: self).weekday
        
        switch weekday {
        case 1:
            return "ראשון"
        case 2:
            return "שני"
        case 3:
            return "שלישי"
        case 4:
            return "רביעי"
        case 5:
            return "חמישי"
        case 6:
            return "שישי"
        case 7:
            return "שבת"
        default:
            return self.formatted(to: .weekday)
        }
    }
}

enum DateFormat: String, CaseIterable {
    case ddMM = "dd/MM"
    case ddMMyy = "dd/MM/yy"
    case ddMMyyyy = "dd/MM/yyyy"
    case weekday = "EEEE"
    case full = "EEEE, MMM d, yyyy"
    case fileName = "yMMdd-HHmmss"
    case hhmm = "hh:mm"
    case HHmm = "HH:mm"
}
