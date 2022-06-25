//
//  CarDataPresentable.swift
//  Car Data
//
//  Created by itay gervash on 25/06/2022.
//

import UIKit

protocol CarDataPresentable: UIViewController {
    
}

extension CarDataPresentable {
    
    func presentDataVC(using carData: CarData) {
        
        guard self.isViewLoaded else { return }
        
        if let destination = K.storyBoards.dataStoryBoard.instantiateViewController(withIdentifier: K.viewControllerIDs.dataVC) as? DataViewController {
            
            destination.licensePlateNumber = String(describing: carData.baseData.plateNumber)
            destination.data = carData
            
            navigationController?.pushViewController(destination, animated: true)
        }
    }
}
