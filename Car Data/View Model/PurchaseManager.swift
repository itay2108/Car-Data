//
//  PremiumManager.swift
//  Car Data
//
//  Created by itay gervash on 24/07/2022.
//

import Foundation
import StoreKit

protocol PurchaseManagerDelegate {
    func purchase(didFinishWith purchaseResult: PurchaseResult, for product: Purchasable?)
    func restorePurchasesFailed(withError error: Error)
    func didFinishRestoringPurchases(_ restoredProducts: [Purchasable])
}

extension PurchaseManagerDelegate {
    func didFinishRestoringPurchases(_ restoredProducts: [Purchasable]) { }
    func restorePurchasesFailed(withError error: Error) { }
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
            delegate?.purchase(didFinishWith: .failure, for: product)
            return
        }
        
        productInQueue = skproduct
        
        let payment = SKPayment(product: skproduct)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
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
    
    func requestAppstoreReview() {
        SKStoreReviewController.requestReview()
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
    
    //Purchases
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.payment.productIdentifier == productInQueue?.productIdentifier {
                
                let purchasableProduct = Purchasable(rawValue: productInQueue?.productIdentifier ?? "")
                if transaction.transactionState == .purchased {
                    delegate?.purchase(didFinishWith: .success, for: purchasableProduct)
                    
                    productInQueue = nil
                    return
                    
                } else if transaction.transactionState == .failed {
                    delegate?.purchase(didFinishWith: .failure, for: purchasableProduct)
                    
                    productInQueue = nil
                    return
                    
                } else if transaction.transactionState == .deferred {
                    delegate?.purchase(didFinishWith: .cancellation, for: purchasableProduct)
                    
                    productInQueue = nil
                    return
                }
            }
        }
        
    }
    
    //Restore
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let transactions = queue.transactions
        var restoredProducts = [Purchasable]()
        
        for transaction in transactions {
            if  (transaction.transactionState == .restored || transaction.transactionState == .purchased),
                let product = Purchasable(rawValue: transaction.payment.productIdentifier) {
                
                restoredProducts.append(product)
            }
        }
        
        if restoredProducts.count > 0 {
            delegate?.didFinishRestoringPurchases(restoredProducts)
        } else {
            delegate?.restorePurchasesFailed(withError: CDError.nothingToRestore)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.restorePurchasesFailed(withError: error)
    }
}

///An enum representing available IAP Product IDs in the raw value
enum Purchasable: String, CaseIterable{
    case premium = "cardataplus"
    case premiumDiscounted = "cardataplus-discount"
    
    var grantsPremiumAccess: Bool {
        switch self {
        case .premiumDiscounted, .premium:
            return true
        default:
            return false
        }
    }
}

enum PurchaseResult {
    case success
    case failure
    case cancellation
}
