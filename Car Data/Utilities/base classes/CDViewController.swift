//
//  CDViewController.swift
//  Car Data
//
//  Created by itay gervash on 31/05/2022.
//

import UIKit
import Hero

class CDViewController: UIViewController, PremiumDisplayable {
    
    var licensePlateNumber: String?
    
    var heroNavigationControllerDelegateCache: UINavigationControllerDelegate?
    
    //MARK: Swipe to dismiss parameters
    
    var allowsSwipeLeftToPopViewController: Bool {
        return false
    }
    
    var popsToMainVC: Bool {
        return false
    }
    
    var swipeableViews: [UIView] {
        return []
    }
    
    private var initialBackSwipePoint: CGPoint?
    
    private var quarterOfScreenWidth: CGFloat {
        return view.frame.width / 4
    }
    
    private var sixthOfScreenHeight: CGFloat {
        return view.frame.height / 6
    }
    
    //premium
    
    var hasPremium: Bool {
        return UserDefaultsManager.main.value(forKey: .hasPremium) as? Bool ?? false
    }
    
    //tableview
    
    var cdTableViewRowHeight: CGFloat = UITableView.automaticDimension
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        hero.isEnabled = true
        hero.modalAnimationType = .push(direction: .left)
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupMainView()
    }
    
    private func setupMainView() {
        guard allowsSwipeLeftToPopViewController else {
            return
        }
        
        let swipeGR = UIPanGestureRecognizer(target: self, action: #selector(screenDidSwipeToDismiss(_:)))
        view.addGestureRecognizer(swipeGR)
        
        for view in swipeableViews {
            let swipeGR = UIPanGestureRecognizer(target: self, action: #selector(screenDidSwipeToDismiss(_:)))
            view.addGestureRecognizer(swipeGR)
        }
    }
    
    @objc private func screenDidSwipeToDismiss(_ sender: UIPanGestureRecognizer) {
        
        guard allowsSwipeLeftToPopViewController else { return }
        
        if sender.state == .began {
            initialBackSwipePoint = sender.location(in: view)
        }
        
        if sender.state == .changed || sender.state == .ended {
            let currentPoint = sender.location(in: view)
            
            guard let initialPoint = initialBackSwipePoint else {
                return
            }
            
            print(initialPoint.x - currentPoint.x)
            
            if (initialPoint.x > view.frame.width * 0.9 && // swipe began on right 10% of screen
                currentPoint.x + (quarterOfScreenWidth / 3) < initialPoint.x) ||
                (initialPoint.x > view.frame.width * 0.66 && // swipe began on right 33% of screen
                 currentPoint.x + quarterOfScreenWidth < initialPoint.x), //current point of swipe is more than a quarter of screen to the left of the initial
               currentPoint.y + sixthOfScreenHeight > initialPoint.y, //current point of swipe is not more than a sixth of screen below the initial
               currentPoint.y - sixthOfScreenHeight < initialPoint.y { //current point of swipe is not more than a sixth of screen above the initial
                
                dismiss()
                sender.finishCurrentGesture()
            }
        }
    }
    
    func dismiss(withDelay delay: TimeInterval = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            
            if self?.popsToMainVC == true {
               if let mainVC = self?.navigationController?.viewControllers.first(where:  { $0 is MainViewController }) {
                   self?.navigationController?.popToViewController(mainVC, animated: true)
               } else {
                   self?.navigationController?.popToRootViewController(animated: true)
               }
            }
            
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    
}
