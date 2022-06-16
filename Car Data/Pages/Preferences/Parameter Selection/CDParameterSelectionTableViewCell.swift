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
    
    lazy var uiSwitch: UISwitch = {
        let uiSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 48 * widthModifier, height: 28 * heightModifier))
        
        uiSwitch.onTintColor = K.colors.accents.dark
        
        uiSwitch.contentMode = .scaleAspectFit
        
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
        
        uiSwitch.transform = CGAffineTransform(scaleX: 0.66, y: 0.66)
        uiSwitch.center = CGPoint(x: (48 * widthModifier / 2) + 16, y: frame.maxY / 2 + 8)
        
        selectionStyle = .none
    }
    
    private func setupViews() {
        addSubview(parameterLabel)
        addSubview(uiSwitch)
    }
    
    private func setupConstraints() {
        
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
