//
//  SearchHistoryTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 02/06/2022.
//

import UIKit
import Hero

class SearchHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var licensePlateLabel: CDLabel!
    @IBOutlet weak var licensePlateLabelWidthAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var modelYearLabel: UILabel!
    
    @IBOutlet weak var searchTimeLabel: UILabel!

    var animationDelay: TimeInterval = 0.1
    
    func configure(with record: DataRecordPreview) {
        mainContainer.layer.cornerRadius = 13
        mainContainer.layer.masksToBounds = true
        
        licensePlateLabel.layer.cornerRadius = 4
        licensePlateLabel.layer.masksToBounds = true
        
        selectionStyle = .none
        
        
        let plateNumber = String(describing: record.plateNumber)
        licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(plateNumber)
        
        let manufacturer = record.manufacturer
        manufacturerLabel.text = manufacturer ?? "יצרן לא ידוע"
        
        let model = record.model
        modelLabel.text = model ?? "דגם לא ידוע"
        
        if let modelYear = record.modelYear {
            modelYearLabel.text = String(describing: modelYear)
        } else {
            modelYearLabel.text = "-"
        }

        //date label setup
        
        let searchDate = record.date
        
        if searchDate.isToday() {
            searchTimeLabel.text = searchDate.formatted(to: .HHmm)
        } else if searchDate.isYesterday() {
            searchTimeLabel.text = "אתמול"
        } else if searchDate.isInPastWeek() {
            searchTimeLabel.text = searchDate.hebrewWeekday()
        } else if searchDate.isInPastYear() {
            searchTimeLabel.text = searchDate.formatted(to: .ddMM)
        } else {
            searchTimeLabel.text = searchDate.formatted(to: .ddMMyy)
        }

        licensePlateLabelWidthAnchor.constant = licensePlateLabel.intrinsicContentSize.width + 16
        
    }
    
}
