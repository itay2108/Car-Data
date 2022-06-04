//
//  DataViewController.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit
import Hero

class DataViewController: CDViewController {

    @IBOutlet weak var headerTitleLabel: UILabel!
    
    
    @IBOutlet weak var licensePlateLabel: PaddingLabel!
    
    @IBOutlet weak var dataTableView: UITableView!
    
    var data: CarData?

    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupHeader()
        setupLicensePlateLabel()
        setupTableView()
    }
    
    private func setupHeader() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerTitleDidTap(_:)))
        headerTitleLabel.addGestureRecognizer(tapGR)
        headerTitleLabel.isUserInteractionEnabled = true
    }
    
    private func setupLicensePlateLabel() {
        
        licensePlateLabel.layer.cornerRadius = 13
        licensePlateLabel.layer.masksToBounds = true
        
        if let plateNumber = data?.plateNumber {
            licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(String(plateNumber))
        } else {
            licensePlateLabel.text = "-"
        }
    }
    
    private func setupTableView() {
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        dataTableView.register(UINib(nibName: DataSectionTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: DataSectionTableViewCell.reuseID)
        
        dataTableView.backgroundColor = .clear
        dataTableView.layer.cornerRadius = 13
        dataTableView.layer.masksToBounds = true
        
        dataTableView.hero.modifiers = [.translate(y: 875)]
    }
    
    private func dismiss() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.licensePlateLabel.heroID = nil
            
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    //MARK: - IB Methods

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss()
    }
    
    @objc private func headerTitleDidTap(_ sender: UITapGestureRecognizer) {
        dismiss()
    }
    
}

extension DataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataSectionTableViewCell.reuseID) as? DataSectionTableViewCell else {
            return UITableViewCell()
        }
        
        var label: String?
        var source: [CDParameter] = []
        
        if indexPath.row == 0 {
            source = data?.topSection() ?? []
            label = "פרטים בסיסיים"
            
        } else if indexPath.row == 1 {
            source = data?.midSection() ?? []
            label = "פרטים נוספים"
        }
        
        cell.configure(withTitle: label, parameters: source)
        
        return cell
        
        
    }
    
}
