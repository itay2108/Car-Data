//
//  RealmManager.swift
//  Car Data
//
//  Created by itay gervash on 16/06/2022.
//

import Foundation
import RealmSwift

struct RealmManager {
    
    static let realm = try? Realm()
    
    static func fetch<T: Object>(recordsOfType recordType: T.Type) -> [T] {
        
        var records: [T] = []
        
        if let results = realm?.objects(recordType) {
            for result in results {
                records.append(result)
            }
        }
        
        return records
    }
    
    static func delete<T: Object>(allRecordsOfType recordType: T.Type) throws {
        
        guard let realm = realm else {
            throw CDError.noRealm
        }
        
        do {
            try realm.write {
                realm.delete(realm.objects(recordType))
            }
        } catch {
            throw CDError.realmFailed
        }
    }
    
    static func delete(record: Object) throws {
        guard let realm = realm else {
            throw CDError.noRealm
        }
        
        do {
            try realm.write {
                realm.delete(record)
            }
        } catch {
            throw CDError.realmFailed
        }
    }
    
    static func save(record: Object) throws {
        
        guard let realm = realm else {
            throw CDError.noRealm
        }
        
        do {
            try realm.write {
                realm.add(record)
            }
        } catch {
            throw CDError.realmFailed
        }
    }
    
}
