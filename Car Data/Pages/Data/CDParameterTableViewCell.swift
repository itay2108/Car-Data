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
    
    @IBOutlet weak var booleanIndicator: UIImageView!
    
    func configure(with parameter: CDParameter?) {
        
        mainContainer.layer.cornerRadius = 13
        mainContainer.layer.masksToBounds = true
        
        parameterNameLabel.text = parameter?.type.rawValue ?? "-"
        
        guard let value = parameter?.value else {
            parameterValueLabel.text = "-"
            return
        }
        
        if let boolValue = value as? Bool {
            parameterValueLabel.isHidden = true
            booleanIndicator.isHidden = false
            
            booleanIndicator.image = boolValue ?
            UIImage(systemName: "checkmark.circle.fill")
            : UIImage(systemName: "xmark.circle.fill")
            
        } else {
            let text = String(describing: value)
            parameterValueLabel.text = text
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        parameterValueLabel.isHidden = false
        booleanIndicator.isHidden = true
    }
    
}
