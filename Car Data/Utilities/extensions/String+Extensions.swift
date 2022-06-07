//
//  String+Extensions.swift
//  Car Data
//
//  Created by itay gervash on 07/06/2022.
//

import Foundation

public extension String {

    //MARK: - Pattern Matching
    
        func match(_ regex: String) -> [[String]] {
            guard let regex = try? NSRegularExpression(pattern: regex, options: []) else {
                return []
            }
            
            let nsString = self as NSString
            
            let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length ))

            return results.map { result in
                (0..<result.numberOfRanges).map {
                    result.range(at: $0).location != NSNotFound
                        ? nsString.substring(with: result.range(at: $0))
                        : ""
                }
            }
        }
    
    func firstMatch(_ regex: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else {
            return self
        }
        
        let nsString = self as NSString
        
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length ))

        return results.map { result in
            (0..<result.numberOfRanges).map {
                result.range(at: $0).location != NSNotFound
                    ? nsString.substring(with: result.range(at: $0))
                    : ""
            }
        }.first?.first ?? self
    }
    
    //MARK: - Date conversion
    
    func asDate(inputFormat: CDdateFormat = .govApiFormat) -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = inputFormat.rawValue
        
        return formatter.date(from: self)
    }
    
    func asDateFormat(inputFormat: CDdateFormat = .govApiFormat, outputFormat: CDdateFormat = .uiFormat) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = inputFormat.rawValue
        
        guard let date = formatter.date(from: self) else {
            return nil
        }
        
        formatter.dateFormat = outputFormat.rawValue
        
        return formatter.string(from: date)
    }
}
