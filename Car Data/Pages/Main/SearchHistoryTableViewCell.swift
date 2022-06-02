//
//  SearchHistoryTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit

class SearchHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var licensePlateLabel: CDLabel!
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var modelYearLabel: UILabel!
    
    @IBOutlet weak var searchTimeLabel: UILabel!

    
    func configure() {
        mainContainer.layer.cornerRadius = 13
        mainContainer.layer.masksToBounds = true
        
        licensePlateLabel.layer.cornerRadius = 4
        licensePlateLabel.layer.masksToBounds = true
        
        selectionStyle = .none
    }
    
}
