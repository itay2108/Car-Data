//
//  PreferencesViewController.swift
//  Car Data
//
//  Created by itay gervash on 14/06/2022.
//

import UIKit
import Hero

class PreferencesViewController: CDTableViewController {

    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet var cells: [UITableViewCell]!
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    //MARK: - UI Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
    }

    override func setupViews() {
        super.setupViews()
        
        setupHeader()
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
    
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(tableView.cellForRow(at: indexPath)?.textLabel?.text)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 15
    }
}
