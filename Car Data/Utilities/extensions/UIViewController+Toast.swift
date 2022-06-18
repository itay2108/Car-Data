//
//  UIViewController+Toast.swift
//  Car Data
//
//  Created by itay gervash on 18/06/2022.
//

import UIKit

extension UIViewController {
    
    enum ToastFeedbackType {
        case normal
        case warning
    }
    
    var isPresentingToast: Bool {
        return view.subviews.contains(where: { $0.heroID == "toast" })
    }
    
    func toast(message: String, feedbackType: ToastFeedbackType = .normal) {
        
        guard !isPresentingToast else {
            
            feedbackType == .normal ? UIImpactFeedbackGenerator(style: .soft).impactOccurred() : UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return
        }
        
        let toastLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - (40 * widthModifier), height: 36 * heightModifier))
        
        toastLabel.font = Rubik.regular.ofSize(15 * heightModifier)
        toastLabel.textColor = K.colors.background
        toastLabel.textAlignment = .center
        toastLabel.textAlignment = .right
        
        toastLabel.text = message
        
        toastLabel.frame = CGRect(x: 0, y: 0, width: toastLabel.intrinsicContentSize.width, height: 36 * heightModifier)
        
        let toastIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: toastLabel.frame.height * 1.5, height: toastLabel.frame.height))
        
        toastIcon.contentMode = .scaleAspectFit
        toastIcon.image = UIImage(systemName: "exclamationmark.circle.fill")
        
        toastIcon.tintColor = K.colors.background
        
        let toastContainer = UIStackView(frame: CGRect(x: 0, y: 0, width: min(toastLabel.frame.width + 48, view.frame.width * 0.8), height: 36 * heightModifier))
        
        toastContainer.alpha = 0
        toastContainer.center = CGPoint(x: view.center.x, y: view.frame.maxY + (36 * heightModifier))
        
        toastContainer.backgroundColor = K.colors.backgroundDark
        
        toastContainer.layer.cornerRadius = 12
        toastContainer.layer.masksToBounds = true
        
        toastContainer.axis = .horizontal
        toastContainer.distribution = .equalSpacing
        
        toastContainer.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 14)
        toastContainer.isLayoutMarginsRelativeArrangement = true
        
        toastContainer.addArrangedSubview(toastLabel)
        toastContainer.addArrangedSubview(toastIcon)
        
        toastContainer.heroID = "toast"
        
        view.addSubview(toastContainer)
        
        UIView.animate(withDuration: 0.166) {
            toastContainer.alpha = 1
        } completion: { finish in
            
            feedbackType == .normal ? UIImpactFeedbackGenerator(style: .soft).impactOccurred() : UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            
            toastContainer.center = CGPoint(x: self.view.center.x, y: self.view.frame.maxY - (36 * self.heightModifier) - self.view.safeAreaInsets.bottom)
            
        } completion: { finish in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                toastContainer.fadeOut() { _ in
                    toastContainer.removeFromSuperview()
                }
            }
        }
        
        
        
        
    }
    
}
