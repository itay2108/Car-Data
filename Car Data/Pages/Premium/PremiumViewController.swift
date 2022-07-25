//
//  PremiumViewController.swift
//  Car Data
//
//  Created by itay gervash on 24/07/2022.
//

import UIKit
import Hero

class PremiumViewController: CDViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var benefitViewBackground: UIView!
    @IBOutlet weak var benefitViewContainer: UIStackView!
    @IBOutlet var benefitViews: [UIView]!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var doubtButton: UIButton!
    
    //MARK: - Parameters
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return false
    }
    
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
        if let price = PurchaseManager.main.localizedPrice(for: .premium) {
            priceLabel.text = "ב- " + price
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
