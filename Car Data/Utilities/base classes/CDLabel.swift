//
//  CDLabel.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit
import PaddingLabel

@IBDesignable class CDLabel: PaddingLabel {
    //MARK: - IBInspectable preperties
    
    @IBInspectable public var cornerRadius: CGFloat = 13 {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - init methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        updateUI()
//    }
    


    // MARK: - UI Setup
    private func setupUI() {
        
        updateUI()
    }


    // MARK: - Update UI
    private func updateUI() {
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false

    }
}
