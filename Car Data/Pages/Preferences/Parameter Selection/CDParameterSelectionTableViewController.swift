//
//  CDParameterSelectionTableViewController.swift
//  Car Data
//
//  Created by itay gervash on 15/06/2022.
//

import UIKit

class CDParameterSelectionTableViewController: CDViewController {
    
    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var searchTerm: String = ""
    
    private let allParameters: [CDParameterType] = CDParameterType.allCases

    private var relevantFilters: [CDParameterType] {
        return searchTerm.count == 0 ? allParameters : allParameters.filter( { $0.rawValue.contains(searchTerm) })
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupTableView()
        setupHeader()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(CDParameterSelectionTableViewCell.self, forCellReuseIdentifier: CDParameterSelectionTableViewCell.reuseID)
        
        tableView.layer.cornerRadius = 13
        tableView.layer.masksToBounds = true
    }
    
    private func setupHeader() {
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerDidTap(_:)))
        
        headerStackView.addGestureRecognizer(tapGR)
    }
    
    //MARK: - Selecors
    
    @objc private func headerDidTap(_ sender: UITapGestureRecognizer) {
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
        
        navigationController?.popViewController(animated: true)
    }

}

extension CDParameterSelectionTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return relevantFilters.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CDParameterSelectionTableViewCell.reuseID) as? CDParameterSelectionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: relevantFilters[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CDParameterSelectionTableViewCell {
            
            cell.uiSwitch.setOn(!cell.uiSwitch.isOn, animate: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "נתוני רכב"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 15
    }

}
