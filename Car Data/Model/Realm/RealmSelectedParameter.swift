//
//  RealmPreferredParameters.swift
//  Car Data
//
//  Created by itay gervash on 16/06/2022.
//

import Foundation
import RealmSwift

class RealmSelectedParameter: Object {
    @Persisted var parameter: CDParameterType = .plateNumber
    @Persisted var target: CDParameterSelectionTarget = .priority
}

enum CDParameterSelectionTarget: Int, PersistableEnum {
    case priority = 0
    case filter = 1
}
