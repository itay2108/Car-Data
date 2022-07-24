//
//  LoaderView.swift
//  Car Data
//
//  Created by itay gervash on 24/07/2022.
//

import UIKit

class LoaderView: UIView {
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: frame.height / 2, height: frame.height / 2))
        
        ac.style = .large
        ac.color = .white
        
        return ac
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black.withAlphaComponent(0.78)
        
        addSubview(activityIndicator)
        
        layer.masksToBounds = true
        layer.cornerRadius = 13
        activityIndicator.center = center
        
        activityIndicator.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
}
