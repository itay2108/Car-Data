//
//  SearchResult.swift
//  Car Data
//
//  Created by itay gervash on 22/06/2022.
//

import UIKit
import RealmSwift

class DataRecord: Object {
    @Persisted var data: RealmCarData? = RealmCarData()
    @Persisted var date: Date = Date()
}
