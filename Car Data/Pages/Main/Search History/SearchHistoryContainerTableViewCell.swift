//
//  SearchHistoryContainerTableViewCell.swift
//  Car Data
//
//  Created by itay gervash on 25/06/2022.
//

import UIKit

protocol SearchHistoryContainerCellDelegate {
    func historyContainer(didSelectCellWith data: CarData, at indexPath: IndexPath)
    func historyContainer(didUpdateSearchTermTo searchTerm: String, matchingRecordsCount count: Int)
}

extension SearchHistoryContainerCellDelegate {
    func historyContainer(didSelectCellWith data: CarData, at indexPath: IndexPath) { }
    func historyContainer(didUpdateSearchTermTo searchTerm: String, matchingRecordsCount count: Int) { }
}

class SearchHistoryContainerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var separatorView: UIView!
    
    var records: [DataRecordPreview] = RealmManager.fetch(recordsOfType: DataRecordPreview.self).sorted(by: { $1.date < $0.date })
    
    var relevantRecords: [DataRecordPreview] {
        return searchTerm.count == 0 ? records : records.filter( { $0.contains(searchTerm) == true })
    }
    
    var searchTerm: String = "" {
        didSet {
            tableView.reloadData()
            mainContainer.backgroundColor = relevantRecords.count == 0 ? .clear : .white
            
            delegate?.historyContainer(didUpdateSearchTermTo: searchTerm, matchingRecordsCount: relevantRecords.count)
        }
    }
    
    var rowHeight: CGFloat = UITableView.automaticDimension
    
    var delegate: SearchHistoryContainerCellDelegate?
    
    func configure(with rowHeight: CGFloat = UITableView.automaticDimension) {
        
        setupTableView()
        
        self.rowHeight = rowHeight
        
        selectionStyle = .none
        
        mainContainer.backgroundColor = relevantRecords.count == 0 ? .clear : .white

    }
    
    private func setupTableView() {
        mainContainer.layer.cornerRadius = 13
        mainContainer.layer.masksToBounds = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: SearchHistoryTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: SearchHistoryTableViewCell.reuseID)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
    
    }

}

extension SearchHistoryContainerTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        relevantRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.reuseID) as? SearchHistoryTableViewCell,
              let record = relevantRecords[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: record)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let dataKey = relevantRecords[safe: indexPath.row]?.key,
           let data = RealmManager.fetch(recordOfType: DataRecord.self, withPrimaryKey: dataKey)?.data?.asCarData()  {
            
            delegate?.historyContainer(didSelectCellWith: data, at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    
}
