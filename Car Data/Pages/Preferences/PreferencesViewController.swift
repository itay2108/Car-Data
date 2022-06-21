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
    @IBOutlet weak var visionAlgorithmTypeLabel: UILabel!
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        visionAlgorithmTypeLabel.text = Def.main.visionAlgorithmType().title()
    }
    
    //MARK: - UI Methods

    override func setupViews() {
        super.setupViews()
        
        setupHeader()
    }
    
    private func setupHeader() {
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerDidTap(_:)))
        
        headerStackView.addGestureRecognizer(tapGR)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
        
        if let destination = segue.destination as? CDParameterSelectionTableViewController {
            if segue.identifier == K.segues.PreferenceStoryboard.preferencesToFilteredData {
                
                destination.target = .filter
                destination.headerTitleText = "פרטים מוסתרים"
                
            } else if segue.identifier == K.segues.PreferenceStoryboard.preferencesToPriorityData {
                
                destination.target = .priority
                destination.headerTitleText = "פרטים מועדפים"
            }
        }
           
    }
    
    //MARK: - Selecors
    
    @objc private func headerDidTap(_ sender: UITapGestureRecognizer) {
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
        
        navigationController?.popViewController(animated: true)
    }
    
    override func dismiss(withDelay delay: TimeInterval = 0) {
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
        
        super.dismiss(withDelay: delay)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        dismiss(withDelay: 0)
    }
    //MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: K.segues.PreferenceStoryboard.preferencesToPriorityData, sender: self)
            case 1:
                performSegue(withIdentifier: K.segues.PreferenceStoryboard.preferencesToFilteredData, sender: self)
            default:
                return
            }
        case 1:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: K.segues.PreferenceStoryboard.pregerencesToVisionAlgorithm, sender: self)
            default:
                return
            }
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height / 15
    }
}
