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
        
        struct accents {
            static let yellow = UIColor(named: "cd-yellow") ?? .yellow
            
            static let dark = UIColor(named: "cd-accent-dark") ?? .blue
            
            static let light = UIColor(named: "cd-accent-light") ?? .lightGray
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
    }
    
    struct segues {
        struct mainStoryboard {
            static let mainToLoadResult = "mainToLoadResult"
            static let loadResultToData = "loadResultToData"
        }
    }
    
    struct URLs {
        static let basicData = "https://data.gov.il/api/3/action/datastore_search?resource_id=053cea08-09bc-40ec-8f7a-156f0677aff3"
        static let extraData = "https://data.gov.il/api/3/action/datastore_search?resource_id=142afde2-6228-49f9-8a29-9b6c3a0cbe40"
        static let diasabilityData = "https://data.gov.il/api/3/action/datastore_search?resource_id=c8b9f9c8-4612-4068-934f-d4acd2e3c06e"
    }
}
