//
//  RNG.swift
//  Car Data
//
//  Created by itay gervash on 23/07/2022.
//

import Foundation

struct RNG {
    
    ///Returns true with a rate of specified probability (out of 100)
    static func probability(of probability: Int) -> Bool {
        guard probability > 0 else { return false }
        
        let range = 1...100
        
        let randomlyGeneratedNumber = Int.random(in: range)
        
        return randomlyGeneratedNumber <= probability
    }
    
    ///Returns a random Double from a range between two provided values
    static func inRange(between minRange: Double, and maxRange: Double) -> Double {
        let range = minRange...maxRange
    
        return Double.random(in: range)
    }
    
}
