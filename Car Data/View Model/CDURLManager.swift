//
//  URLManager.swift
//  Car Data
//
//  Created by itay gervash on 05/06/2022.
//

import Foundation

struct CDURLManager {
    
    func url(from string: String?, query: String? = nil, limit: Int? = nil) -> URL? {
        guard var base = string else {
            return nil
        }
        
        if let query = query {
            base += "&q=\(query)"
        }
        
        if let limit = limit {
            base += "&limit=\(limit)"
        }
        
        guard let encodedBase = base.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return URL(string: base)
        }
        
        return URL(string: encodedBase)
    }
    
    func url(from string: String?, queries: [String] = [], limit: Int? = nil) -> URL? {
        guard var base = string else {
            return nil
        }
        
        for query in queries {
            let formattedQuery = query.replacingOccurrences(of: " ", with: "%20")
            
            base += "&q=\(formattedQuery)"
        }
        
        if let limit = limit {
            base += "&limit=\(limit)"
        }
        
        guard let encodedBase = base.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else {
            return URL(string: base)
        }
        
        return URL(string: encodedBase)
    }
    
    static func deleteFile(from url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            } catch {
                throw CDError.deletionFailed
            }
        }
    }
}
