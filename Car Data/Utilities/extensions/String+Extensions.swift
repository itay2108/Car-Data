//
//  String+Extensions.swift
//  Car Data
//
//  Created by itay gervash on 07/06/2022.
//

import Foundation

public extension String {
    
    func excluding(characrers charactersToExclude: String) -> String {
        
        var newString = self
        
        for character in charactersToExclude {
            newString = newString.replacingOccurrences(of: String(character), with: "")
        }
        
        return newString
    }
    
    func contains(only allowedCharacters: String) -> Bool {
        return self.allSatisfy( { "1234567890".contains($0) })
    }
    
    func including(only allowedCharacters: String) -> String {
        return self.filter { allowedCharacters.contains($0) }
    }

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
