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
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    var headerTitleText: String = ""
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    private var searchTerm: String = ""
    
    private let allParameters: [(Int, [CDParameterType])] = CDParameterType.allSections()

    private var relevantFilters: [(Int, [CDParameterType])] {
        
        return allParameters.map({ (index, section) in
            return searchTerm.count == 0 ? (index, section) : (index, section.filter( {$0.rawValue.contains(searchTerm) }))
        }).compactMap { (index, section) in
            return section.count == 0 ? nil : (index, section)
        }
    }
    
    var target: CDParameterSelectionTarget = .priority
    
    private var selectedParameters: [RealmSelectedParameter] {
        return RealmManager.fetch(recordsOfType: RealmSelectedParameter.self).filter( { $0.target == target })
    }
    
    //MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        resetButton.fadeIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        headerTitle.text = headerTitleText
        
        setupTableView()
        setupHeader()
        setupSearchbar()
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
    
    private func setupSearchbar() {
        searchBar.searchTextField.textAlignment = .right
        searchBar.delegate = self
    }
    
    //MARK: - Selecors
    
    @objc private func headerDidTap(_ sender: UITapGestureRecognizer) {
        
        if sender.location(in: headerStackView).x > headerStackView.frame.maxX * 0.75 {
            navigationController?.popViewController(animated: true)
        }
        

    }

    @IBAction func headerBackButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        do {
            try RealmManager.realm?.write {
                RealmManager.realm?.delete(selectedParameters)
                
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                tableView.reloadData()
            }
        } catch {
            presentErrorAlert(with: CDError.realmFailed)
        }
    }
}

extension CDParameterSelectionTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source


    func numberOfSections(in tableView: UITableView) -> Int {
        return relevantFilters.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let section = relevantFilters[safe: section]?.1 {
            return section.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CDParameterSelectionTableViewCell.reuseID) as? CDParameterSelectionTableViewCell,
            let section = relevantFilters[safe: indexPath.section]?.1,
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
            
            if selectedParameters.count >= 5 && target == .priority && !cell.uiSwitch.isOn {
                
                toast(message: "ניתן לתעדף עד 5 פרמטרים", feedbackType: .warning)
                return
            }
            
            
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
        
        guard let sectionNumber = relevantFilters[safe: section]?.0 else {
            return nil
        }
        
        switch sectionNumber {
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

extension CDParameterSelectionTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchTerm = searchText
        
        tableView.reloadData()
    }
}
