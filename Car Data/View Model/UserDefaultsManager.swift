//
//  UserDefaultsManager.swift
//  Car Data
//
//  Created by itay gervash on 21/06/2022.
//

import Foundation

typealias Def = UserDefaultsManager

class UserDefaultsManager {
    
    static let main = UserDefaultsManager()
    
    private let def = UserDefaults.standard
    
    func visionAlgorithmType() -> VisionAlgorithmType {
        if let rawType = value(forKey: .visionAlgorithmStyle) as? Int,
            let type = VisionAlgorithmType(rawValue: rawType) {
            return type
        } else {
            return .standard
        }
    }
    
    func updateAlgorithmType(to newType: VisionAlgorithmType) {
        setValue(newType.rawValue, forKey: .visionAlgorithmStyle)
    }
    
    
    //MARK: Base Mathods
    
    func value(forKey key: UserDefaultKey) -> Any? {
        return def.object(forKey: key.rawValue)
    }
    
    func value(forString key: String) -> Any? {
        return def.object(forKey: key)
    }
    
    func setValue(_ value: Any, forKey key: UserDefaultKey) {
        def.set(value, forKey: key.rawValue)
    }
    
    func setValue(_ value: Any, forString key: String) {
        def.set(value, forKey: key)
    }
}

enum UserDefaultKey: String {
    case visionAlgorithmStyle = "visionAlgorithmStyle"
    case hasPremium = "hasPremium"
}
