//
//  CDTableView.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit

class CDTableView: UITableView {
    
    // MARK: - init methods
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        //.adjustedContentInset =
        self.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 0)
        
        self.layer.cornerRadius = 13
        self.layer.masksToBounds = true

        self.backgroundColor = .white
    }
    


}
