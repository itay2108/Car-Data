//
//  UIAlertController+Error.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit

extension UIViewController {
    func presentRetryableErrorAlert(with errorInfo: Error, withDescription showsDescription: Bool = true, canRetry: Bool = false, retryHandler: (()->Void)? = nil) {
        
        let alert = UIAlertController(title: "אופס, אירעה שגיאה", message: errorInfo.localizedDescription, preferredStyle: .alert)
        
        if !showsDescription { alert.message = nil }
        
        let dismissAction = UIAlertAction(title: "הבנתי", style: .cancel)
        
        if canRetry {
            let retryAction = UIAlertAction(title: "נסיון חוזר", style: .default) { action in
                retryHandler?()
            }
            
            alert.addAction(retryAction)
        }
        
        alert.addAction(dismissAction)
        
        present(alert, animated: true)
        
    }
    
    func presentErrorAlert(with errorInfo: Error, withDescription showsDescription: Bool = true, customDesription: String? = nil, actions: [UIAlertAction]? = nil) {
        
        let alert = UIAlertController(title: "משהו השתבש", message: errorInfo.localizedDescription, preferredStyle: .alert)
        
        if !showsDescription { alert.message = nil }
        if let customDesription = customDesription {
            alert.message = customDesription
        }
        
        if let error = errorInfo as? CDError {
            alert.message = error.localizedDescription
        }
        
        let dismissAction = UIAlertAction(title: "הבנתי", style: .cancel)
        
        if let actions = actions, actions.count > 0 {
            for action in actions {
                alert.addAction(action)
            }
        } else {
            alert.addAction(dismissAction)
        }
        
        present(alert, animated: true)
        
    }
}
