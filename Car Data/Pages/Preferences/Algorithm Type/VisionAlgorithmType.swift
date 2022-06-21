//
//  VisionAlgorithmType.swift
//  Car Data
//
//  Created by itay gervash on 21/06/2022.
//

import Foundation

enum VisionAlgorithmType: Int, CaseIterable {
    case accurate = -1
    case standard = 0
    case fast = 1
    
    func title() -> String {
        switch self {
        case .accurate:
            return "מדויק"
        case .standard:
            return "סטנדרטי"
        case .fast:
            return "מהיר"
        }
    }
    
    func sampleThreshold() -> Int {
        switch self {
        case .accurate:
            return 33
        case .fast:
            return 9
        default:
            return 19
        }
    }
}
