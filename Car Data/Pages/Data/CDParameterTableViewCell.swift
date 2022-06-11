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
        
        //handle boolean values (convert to V or X icon)
        if let boolValue = value as? Bool {
            parameterValueLabel.isHidden = true
            booleanIndicator.isHidden = false
            
            booleanIndicator.image = boolValue ?
            UIImage(systemName: "checkmark.circle.fill")
            : UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(K.colors.accents.light.withAlphaComponent(0.33))
            
        } else {
            //handle non boolean values
            let text = String(describing: value)
            parameterValueLabel.text = text
        }
        
        updateMOTbackgroundWarningColor(for: parameter)
        updateTotalLossWarningColor(for: parameter)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        parameterValueLabel.isHidden = false
        booleanIndicator.isHidden = true
        
        mainContainer.backgroundColor = K.colors.background
    }
    
    private func updateMOTbackgroundWarningColor(for field: CDParameter?) {
        
        if field?.type == .nextMOT,
           let motDate = (field?.value as? String)?.asDate(inputFormat: .uiFormat) {
            
            if motDate.isInThePast() {
                mainContainer.backgroundColor = K.colors.accents.error

            } else if let daysUntilMOT = Calendar.current.dateComponents([.day], from: Date(), to: motDate).day,
                daysUntilMOT <= 30 {
                mainContainer.backgroundColor = K.colors.accents.warning
            }
        }
    }
    
    private func updateTotalLossWarningColor(for field: CDParameter?) {
        
        if field?.type == .totalLossDate {
            
            mainContainer.backgroundColor = K.colors.accents.error
        }
    }
    
}
