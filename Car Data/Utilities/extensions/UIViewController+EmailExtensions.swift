//
//  EmailSendable.swift
//  Car Data
//
//  Created by itay gervash on 25/07/2022.
//

import UIKit
import MessageUI

extension UIViewController: MFMailComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) { [weak self] in
            
            if let _ = error {
                self?.presentErrorAlert(with: CDError.emailError)
            } else if result == .sent {
                let alert = UIAlertController(title: "תודה", message: "קיבלנו את הפניה ונדאכ להיענות בהקדם האפשרי", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "הבנתי", style: .cancel)
                alert.addAction(okAction)
                
                self?.present(alert, animated: true)
            }
        }
    
    }
    
    func sendProblemReportToEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@car-data.co.il"])
            mail.setSubject("דיווח על בעיה בקאר דאטה")
            
            mail.setMessageBody("היי, רציתי לדווח על בעיה באפליקציה - \n\n", isHTML: false)

            present(mail, animated: true)
        } else {
            presentErrorAlert(with: CDError.emailUnavailable)
        }
    }
    
    func sendSuggestionToEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@car-data.co.il"])
            mail.setSubject("התלבטות בנוגע לרכישת קארדאטה+")
            
            mail.setMessageBody("היי,\n\nאני בהתלבטות אם להרשם לקארדאטה+ ו", isHTML: false)

            present(mail, animated: true)
        } else {
            presentErrorAlert(with: CDError.emailUnavailable)
        }
    }
}
