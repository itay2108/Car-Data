//
//  DataTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 04/06/2022.
//

import UIKit

protocol DataSectionTableViewCellDelegate {
    func didLongPress(parameterCellOf type: CDParameter)
    func didLongPress(parameterCellWith value: Any?)
}

extension DataSectionTableViewCellDelegate {
    func didLongPress(parameterCellOf type: CDParameter) { }
    func didLongPress(parameterCellWith value: Any?) { }
}

class DataSectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainContainer: UIView!
    
    @IBOutlet weak var sectionHeader: UILabel!
    
    @IBOutlet weak var parameterTableView: UITableView!
    
    @IBOutlet weak var separatorView: UIView!
    
    var parameters: [CDParameter]? {
        didSet {
            parameterTableView.reloadData()
        }
    }
    
    var delegate: DataSectionTableViewCellDelegate?
    
    func configure(with section: CDParameterSection) {

        if let sectionName = section.title {
            sectionHeader.text = sectionName
        } else {
            sectionHeader.isHidden = true
        }
        
        setupTableView()
        
        self.parameters = section.parameters
        
        selectionStyle = .none
        
    }
    
    private func setupTableView() {
        parameterTableView.register(UINib(nibName: CDParameterTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: CDParameterTableViewCell.reuseID)
        
        mainContainer.layer.cornerRadius = 13
        mainContainer.layer.masksToBounds = true
        
        parameterTableView.dataSource = self
        parameterTableView.delegate = self
        
        parameterTableView.separatorStyle = .none
        
        let longPressGR:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tableViewDidLongPress(_:)))
        longPressGR.minimumPressDuration = 0.4
        
        parameterTableView.addGestureRecognizer(longPressGR)
    }
    
    @objc func tableViewDidLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: parameterTableView)
            
            if let indexPath = parameterTableView.indexPathForRow(at: touchPoint),
               let cell = parameterTableView.cellForRow(at: indexPath) as? CDParameterTableViewCell,
               let parameter = cell.parameter {
                
                delegate?.didLongPress(parameterCellOf: parameter)
            }
        }
    }
    
}

extension DataSectionTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let parametersCount = parameters?.count ?? 0
        let height: CGFloat = CGFloat(parametersCount * 67)
        
        tableView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        
        return parametersCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CDParameterTableViewCell.reuseID) as? CDParameterTableViewCell else {
            return UITableViewCell()
        }
        
        
        cell.configure(with: parameters?[safe: indexPath.row])
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }
    
    
}
