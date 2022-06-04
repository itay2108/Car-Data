//
//  CDParameterTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 04/06/2022.
//

import UIKit

class CDParameterTableViewCell: UITableViewCell {

    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var parameterNameLabel: UILabel!
    
    @IBOutlet weak var parameterValueLabel: UILabel!
    
    func configure(with parameter: CDParameter?) {
        
        mainContainer.layer.cornerRadius = 13
        mainContainer.layer.masksToBounds = true
        
        parameterNameLabel.text = parameter?.type.rawValue ?? "-"
        
        if let value = parameter?.value {
            let text = String(describing: value)
            parameterValueLabel.text = text
        } else {
            parameterValueLabel.text = "-"
        }
    }
    
}
