//
//  CDParameterSelectionTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 15/06/2022.
//

import UIKit
import Switches

class CDParameterSelectionTableViewCell: UITableViewCell {
    
    lazy var parameterLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .right
        label.font = Rubik.regular.ofSize(13 * heightModifier)
        label.textColor = K.colors.text.dark
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var uiSwitch: YapLiquidSwitch = {
       let uiSwitch = YapLiquidSwitch()
        
        uiSwitch.offColor = .lightGray
        uiSwitch.onColor = K.colors.accents.light
        
        uiSwitch.contentMode = .scaleAspectFit
        
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        return uiSwitch
    }()
    
    var parameterType: CDParameterType?

    
    func configure(with cdParameter: CDParameterType) {
        parameterType = cdParameter
        
        parameterLabel.text = cdParameter.rawValue
    }

    
    private func setupUI() {
        setupViews()
        setupConstraints()
        
        selectionStyle = .none
    }
    
    private func setupViews() {
        addSubview(parameterLabel)
        addSubview(uiSwitch)
    }
    
    private func setupConstraints() {
        uiSwitch.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 24).isActive = true
        uiSwitch.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.28).isActive = true
        uiSwitch.widthAnchor.constraint(equalTo: uiSwitch.heightAnchor, multiplier: 2.1).isActive = true
        uiSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        parameterLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -24).isActive = true
        parameterLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.45).isActive = true
        parameterLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        parameterLabel.leftAnchor.constraint(lessThanOrEqualTo: uiSwitch.rightAnchor, constant: 24).isActive = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
