//
//  CDParameterSelectionTableViewController.swift
//  Car Data
//
//  Created by itay gervash on 15/06/2022.
//

import UIKit
import RealmSwift

class CDParameterSelectionTableViewController: CDViewController {
    
    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    private var searchTerm: String = ""
    
    private let allParameters: [[CDParameterType]] = CDParameterType.allSections()

    private var relevantFilters: [[CDParameterType]] {
        return allParameters.map { section in
            return searchTerm.count == 0 ? section : section.filter( {$0.rawValue.contains(searchTerm) })
        }
    }
    
    var target: CDParameterSelectionTarget = .priority
    
    private var selectedParameters: [RealmSelectedParameter] {
        return RealmManager.fetch(recordsOfType: RealmSelectedParameter.self).filter( { $0.target == target })
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


    func numberOfSections(in tableView: UITableView) -> Int {
        relevantFilters.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let section = relevantFilters[safe: section] {
            return section.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CDParameterSelectionTableViewCell.reuseID) as? CDParameterSelectionTableViewCell,
            let section = relevantFilters[safe: indexPath.section],
            let parameter = section[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: parameter)

        
        cell.uiSwitch.isOn = selectedParameters.contains(where: { $0.parameter == parameter })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CDParameterSelectionTableViewCell,
           let parameter = cell.parameterType {
            
            
            do {
                if cell.uiSwitch.isOn {
                    try RealmManager.realm?.write {
                        RealmManager.realm?.delete(selectedParameters.filter( {$0.parameter == parameter }))
                    }
                } else {
                    let realmParameter = RealmSelectedParameter()
                    realmParameter.parameter = parameter
                    realmParameter.target = target
                    
                    try RealmManager.save(record: realmParameter)
                }
            } catch {
                presentErrorAlert(with: error)
            }
            
            cell.uiSwitch.setOn(!cell.uiSwitch.isOn, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "פרטים בסיסיים"
        case 1:
            return "פרטים טכניים"
        case 2:
            return "פרטי רישוי"
        case 3:
            return "פרטים נוספים"
        case 4:
            return "פרטי בטיחות"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 15
    }

}
