//
//  PremiumViewController.swift
//  Car Data
//
//  Created by itay gervash on 24/07/2022.
//

import UIKit
import Hero

enum PremiumType {
    case normal
    case discounted
}

class PremiumViewController: CDViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var benefitViewBackground: UIView!
    @IBOutlet weak var benefitViewContainer: UIStackView!
    @IBOutlet var benefitViews: [UIView]!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var doubtButton: UIButton!
    
    //MARK: - Parameters
    
    var premiumType: PremiumType = .normal
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return false
    }
    
    private lazy var doubtAlert: UIAlertController = {
        let ac = UIAlertController(title: "מובן לגמרי!", message: "בנינו את קאר דאטה שתהיה הכי טובה שאפשר, ועדיין, תמיד יש מה להוסיף. נשמח לשמוע מה תרצו לראות ברגסאות עתידיות ולהשתפר בשבילכם.", preferredStyle: .alert)
        
        let optInAction = UIAlertAction(title: "ספרו לנו", style: .default) { action in
            
            ac.dismiss(animated: true) { [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) {
                    self?.sendSuggestionToEmail()
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "ביטול", style: .default) { action in
            ac.dismiss(animated: true)
        }
        
        ac.addAction(optInAction)
        ac.addAction(cancelAction)
        
        return ac
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.heroNavigationAnimationType = .pull(direction: .down)
        
        PurchaseManager.main.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        PurchaseManager.main.delegate = nil
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupBenefitViews()
        setupPriceLabel()
        
        purchaseButton.layer.masksToBounds = true
        purchaseButton.layer.cornerRadius = 13
        
        //doubtButton.isHidden = true
        
    }
    
    private func setupBenefitViews() {
        
        benefitViewBackground.layer.masksToBounds = true
        benefitViewBackground.layer.cornerRadius = 13
        
        for view in benefitViews {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 13
        }
    }
    
    private func setupPriceLabel() {
        
        if premiumType == .normal {
            if let price = PurchaseManager.main.localizedPrice(for: .premium) {
                priceLabel.text = "ב- " + price
            }
        } else {
            if let discountedprice = PurchaseManager.main.localizedPrice(for: .premiumDiscounted) {
                priceLabel.text = "ב- " + discountedprice
                
                if let normalPrice = PurchaseManager.main.localizedPrice(for: .premium) {
                    priceLabel.text?.append(" במקום ב- \(normalPrice)")
                }
            }
        }

    }
    
    //MARK: - IBActions
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss()
    }
    
    @IBAction func purchaseButtonPressed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        PurchaseManager.main.purchase(.premium)
        
        showLoader()
        purchaseButton.isUserInteractionEnabled = false
    }
    
    @IBAction func doubtButtonPressed(_ sender: UIButton) {
        present(doubtAlert, animated: true)
    }
}

extension PremiumViewController: PurchaseManagerDelegate {
    func purchase(didFinishWith purchaseResult: PurchaseResult, for product: Purchasable?) {
        hideLoader()
        purchaseButton.isUserInteractionEnabled = true
        
        switch purchaseResult {
        case .success:
            
            if product?.grantsPremiumAccess == true {
                UserDefaultsManager.main.setValue(true, forKey: .hasPremium)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                
                self?.dismiss()
            }
        case .failure:
            
            presentErrorAlert(with: CDError.purchaseFailed)
        
        case .cancellation:
            presentErrorAlert(with: CDError.purchaseCancelled)
        }
    }
    
}
