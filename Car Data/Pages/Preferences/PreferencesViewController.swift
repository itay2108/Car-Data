//
//  PreferencesViewController.swift
//  Car Data
//
//  Created by itay gervash on 14/06/2022.
//

import UIKit
import Hero
import MessageUI

class PreferencesViewController: CDTableViewController {

    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet var cells: [UITableViewCell]!
    
    @IBOutlet weak var visionAlgorithmTypeLabel: UILabel!
    
    @IBOutlet weak var premiumCell: UITableViewCell!
    
    
    //MARK: - Parameters
    
    private lazy var dataDeletionAlert: UIAlertController = {
        let alert = UIAlertController(title: "אזהרה!", message: "פעולה זו תמחק את כל החיפושים שבוצעו עד כה ותאפס את כל ההגדרות לברירת המחדל. אין אפשרות לבטל פעולה זו!", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "ביטול", style: .cancel)
        
        let deleteAction = UIAlertAction(title: "איפוס", style: .destructive) { [weak self] _ in
            
            do {
                try RealmManager.resetAll(password: "I am sure")
                
                UserDefaultsManager.main.updateAlgorithmType(to: .standard)
            } catch {
                self?.presentErrorAlert(with: error)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        return alert
    }()
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    override var swipeableViews: [UIView] {
        return [tableView]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        visionAlgorithmTypeLabel.text = Def.main.visionAlgorithmType().title()
        
        updateViewForPremium()
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
    
    private func updateViewForPremium() {
        if hasPremium {
            for cell in cells {
                cell.imageView?.image = nil
            }
            premiumCell.isHidden = true
            tableView.reloadData()
        }
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
            //prioritize data
            case 0:
                if !hasPremium {
                    showPremiumViewController()
                } else {
                    performSegue(withIdentifier: K.segues.PreferenceStoryboard.preferencesToPriorityData, sender: self)
                }
            //filter data
            case 1:
                if !hasPremium {
                    showPremiumViewController()
                } else {
                    performSegue(withIdentifier: K.segues.PreferenceStoryboard.preferencesToFilteredData, sender: self)
                }
            default:
                return
            }
        case 1:
            switch indexPath.row {
            //vision algorithm
            case 0:
                performSegue(withIdentifier: K.segues.PreferenceStoryboard.pregerencesToVisionAlgorithm, sender: self)
            default:
                return
            }
        case 2:
            switch indexPath.row {
            //restore purchases
            case 0:
                PurchaseManager.main.delegate = self
                
                showLoader()
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                
                PurchaseManager.main.restore()

            //rating
            case 1:
                toast(message: "דירוג יתאפשר כשקארדאטה תושק", additionalOffset: -34)
            //report a problem
            case 2:
                sendProblemReportToEmail()
            //clear data
            case 3:
                present(dataDeletionAlert, animated: true)
            default:
                return
            }
        case 3:
            switch indexPath.row {
            case 0:
                guard PurchaseManager.main.isReady else {
                    toast(message: "אופס, קארדאטה+ לא זמין כרגע", feedbackType: .warning, timeoutStyle: .normal, additionalOffset: -34 * heightModifier)
                    return
                }
                
                showPremiumViewController()
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

extension PreferencesViewController: PurchaseManagerDelegate {
    func purchase(didFinishWith purchaseResult: PurchaseResult, for product: Purchasable?) { }
    
    func didFinishRestoringPurchases(_ restoredProducts: [Purchasable]) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
        hideLoader()
        PurchaseManager.main.delegate = nil
        
        if restoredProducts.contains(where: { $0 == .premium || $0 == .premiumDiscounted }) {
            
            UserDefaultsManager.main.setValue(true, forKey: .hasPremium)
            
            updateViewForPremium()
        }
        
        toast(message: "הרכישות שלך שוחזרו בהצלחה!", feedbackType: .warning, timeoutStyle: .normal, additionalOffset: -34 * heightModifier)
    }
    
    func restorePurchasesFailed(withError error: Error) {
        hideLoader()
        PurchaseManager.main.delegate = nil
        
        if let error = error as? CDError, error == .nothingToRestore {
            toast(message: "לא מצאנו רכישות לשחזר", feedbackType: .warning, timeoutStyle: .normal, additionalOffset: -34 * heightModifier)
        } else {
            presentErrorAlert(with: (error as? CDError) ?? error)
        }
        
    }
}
