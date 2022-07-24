//
//  PremiumManager.swift
//  Car Data
//
//  Created by itay gervash on 24/07/2022.
//

import Foundation
import StoreKit

protocol PurchaseManagerDelegate {
    func purchase(didFinishWith purchaseResult: PurchaseResult)
    func didRestorePurchases()
}

extension PurchaseManagerDelegate {
    func didRestorePurchases() { }
}

///Manages in app purchases. Call setup() to make purchases available.
class PurchaseManager: NSObject {
    
    static let main = PurchaseManager()
    
    private var availableProducts = [Purchasable: SKProduct]()
    var isReady: Bool = false
    
    private var productInQueue: SKProduct?
    
    var delegate: PurchaseManagerDelegate?
    
    func purchase(_ product: Purchasable) {
        guard let skproduct = availableProducts[product] else {
            delegate?.purchase(didFinishWith: .failure)
            return
        }
        
        productInQueue = skproduct
        
        let payment = SKPayment(product: skproduct)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        
    }
    
    func localizedPrice(for product: Purchasable) -> String? {
        
        guard let skproduct = availableProducts[product] else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skproduct.priceLocale
        
        return formatter.string(from: skproduct.price)
    }
    
    func setup() {
        let ids = Purchasable.allCases.map( { $0.rawValue })
        let request = SKProductsRequest(productIdentifiers: Set(ids))
        
        request.delegate = self
        request.start()
        
        SKPaymentQueue.default().add(self)
    }
    
    func kill() {
        SKPaymentQueue.default().remove(self)
    }
    
}

extension PurchaseManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        guard response.products.count > 0 else {
            return
        }
        
        for product in response.products {
            guard let purchasable = Purchasable(rawValue: product.productIdentifier) else {
                continue
            }
            
            availableProducts[purchasable] = product
        }
        
        if availableProducts.count > 0 && SKPaymentQueue.canMakePayments() {
            isReady = true
        }
    }
    
    
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.payment.productIdentifier == productInQueue?.productIdentifier {
                
                if transaction.transactionState == .purchased {
                    delegate?.purchase(didFinishWith: .success)
                    
                    productInQueue = nil
                    return
                    
                } else if transaction.transactionState == .failed || transaction.transactionState == .deferred {
                    delegate?.purchase(didFinishWith: .failure)
                    
                    productInQueue = nil
                    return
                    
                }
            }
        }
        
    }
    
    
}

///An enum representing available IAP Product IDs in the raw value
enum Purchasable: String, CaseIterable{
    case premium = "cardataplus"
    case premiumDiscounted = "cardataplus-discount"
}

enum PurchaseResult {
    case success
    case failure
}
