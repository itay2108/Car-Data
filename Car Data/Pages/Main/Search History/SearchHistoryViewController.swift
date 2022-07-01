//
//  SearchHistoryViewController.swift
//  Car Data
//
//  Created by itay gervash on 05/06/2022.
//

import UIKit
import Hero

class SearchHistoryViewController: CDViewController, CarDataPresentable {
    
    
    @IBOutlet weak var headerView: UIStackView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewShadowView: UIView!
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    private var relevantRecordsCount: Int = RealmManager.fetch(recordsOfType: DataRecord.self).filter( { $0.data != nil }).count {
        didSet {
            resultCountLabel.text = "\(relevantRecordsCount) תוצאות"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.hero.modifiers = [.fade, .delay(0.166), .translate(x: 0, y: 20, z: 0), .duration(0.533)]

        tableViewShadowView.hero.modifiers = [.fade, .delay(0.166), .translate(x: 0, y: 30, z: 0), .duration(0.7)]
    }

    override func setupViews() {
        super.setupViews()
        
        setupHeaderView()
        setupSearchbar()
        setupTableView()
    }
    
    private func setupHeaderView() {
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerDidTap(_:)))
        
        headerView.addGestureRecognizer(tapGR)
    }
    
    private func setupSearchbar() {
        searchBar.delegate = self
        
        resultCountLabel.text = "\(relevantRecordsCount) תוצאות"
    }
    
    private func setupTableView() {
        
        tableView.layer.cornerRadius = 13
        tableView.layer.masksToBounds = true

        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: SearchHistoryContainerTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: SearchHistoryContainerTableViewCell.reuseID)

        
        //shadow view setup
        
        tableViewShadowView.layer.shadowColor = K.colors.accents.dark.cgColor
        tableViewShadowView.layer.shadowOpacity = 0.25
        tableViewShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        tableViewShadowView.layer.shadowRadius = 20 * widthModifier
        tableViewShadowView.backgroundColor = .clear
        
    }
    
    //MARK: - Selectors
    
    @objc private func headerDidTap(_ sender: UITapGestureRecognizer) {
        
        let touchPointX = sender.location(in: headerView).x
        let validRange = headerTitleLabel.frame.minX...headerView.frame.maxX
        
        if validRange.contains(touchPointX) {
            
            navigationController?.heroNavigationAnimationType = .slide(direction: .left)
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func dismiss(withDelay delay: TimeInterval = 0) {
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
        
        super.dismiss(withDelay: delay)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss()
    }
}

extension SearchHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryContainerTableViewCell.reuseID) as? SearchHistoryContainerTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: cdTableViewRowHeight)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(relevantRecordsCount) * cdTableViewRowHeight + 72
    }
    
}

extension SearchHistoryViewController: SearchHistoryContainerCellDelegate {
    
    func historyContainer(didSelectCellWith data: CarData, at indexPath: IndexPath) {
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
        presentDataVC(using: data)
    }
    
    func historyContainer(didUpdateSearchTermTo searchTerm: String, matchingRecordsCount count: Int) {
        relevantRecordsCount = count
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension SearchHistoryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SearchHistoryContainerTableViewCell {
        
            cell.searchTerm = searchText

        }
    }
}

