//
//  K.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit

struct K {
    
    struct colors {
        
        static let background = UIColor(named: "cd-background") ?? .white
        
        static let backgroundDark = UIColor(named: "cd-background-dark") ?? .black
        
        struct accents {
            static let yellow = UIColor(named: "cd-yellow") ?? .yellow
            
            static let dark = UIColor(named: "cd-accent-dark") ?? .blue
            
            static let light = UIColor(named: "cd-accent-light") ?? .lightGray
            
            static let error = UIColor(named: "cd-accent-red") ?? .red
            
            static let warning = UIColor(named: "cd-accent-yellow") ?? .yellow
        }
        
        struct text {
            static let dark = UIColor(named: "cd-text-dark") ?? .darkGray
            
            static let light = UIColor(named: "cd-text-light") ?? .blue
        }

    }
    
    struct storyBoards {
       static let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
       static let dataStoryBoard = UIStoryboard(name: "Data", bundle: nil)
    }
    
    struct viewControllerIDs {
        static let dataVC = "dataViewController"
        static let loadResult = "loadResult"
    }
    
    struct segues {
        struct mainStoryboard {
            static let mainToLoadResult = "mainToLoadResult"
            static let loadResultToData = "loadResultToData"
        }
    }
    
    struct URLs {
        static let basicData = "https://data.gov.il/api/3/action/datastore_search?resource_id=053cea08-09bc-40ec-8f7a-156f0677aff3"
        static let basicImportData = "https://data.gov.il/api/3/action/datastore_search?resource_id=03adc637-b6fe-402b-9937-7c3d3afc9140"
        static let motoData = "https://data.gov.il/api/3/action/datastore_search?resource_id=bf9df4e2-d90d-4c0a-a400-19e15af8e95f"
        static let extraData = "https://data.gov.il/api/3/action/datastore_search?resource_id=142afde2-6228-49f9-8a29-9b6c3a0cbe40"
        static let diasabilityData = "https://data.gov.il/api/3/action/datastore_search?resource_id=c8b9f9c8-4612-4068-934f-d4acd2e3c06e"
        static let recallData = "https://data.gov.il/api/3/action/datastore_search?resource_id=36bf1404-0be4-49d2-82dc-2f1ead4a8b93"
        static let inactiveData = "https://data.gov.il/api/3/action/datastore_search?resource_id=f6efe89a-fb3d-43a4-bb61-9bf12a9b9099"
        static let totaledData = "https://data.gov.il/api/3/action/datastore_search?resource_id=851ecab1-0622-4dbe-a6c7-f950cf82abf9"
        static let heavyData = "https://data.gov.il/api/3/action/datastore_search?resource_id=cd3acc5c-03c3-4c89-9c54-d40f93c0d790"
    }
    
    struct regex {
        static let date = "^[[:digit:]]{4}[-\\/.]{1}[[:digit:]]{2}[-\\/.]{1}[[:digit:]]{2}[^\"]*?"
        static let licensePlate = "^(?=.{5,10}$)[[:digit:]]{1,3}[-.•]?[[:digit:]]{1,3}[-.•]?[[:digit:]]{1,3}[^[\\pL]$"
    }
    
    struct queueIDs {
        static let prefix = "com.gervash.Car-Data"
        static let captureSession = "com.gervash.Car-Data.CaptureSessionQueue"
        static let videoOutputSession = "com.gervash.Car-Data.VideoDataOutputQueue"
    }
}
