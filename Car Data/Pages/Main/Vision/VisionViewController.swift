//
//  VisionViewController.swift
//  Car Data
//
//  Created by itay gervash on 08/06/2022.
//

import UIKit
import Vision
import Hero

protocol VisionViewDelegate {
    func visionViewDidCancelSearch()
}

extension VisionViewDelegate {
    func visionViewDidCancelSearch() { }
}


class VisionViewController: CDViewController {

    @IBOutlet weak var visionView: UIView!
    
    @IBOutlet weak var instructionLabel: PaddingLabel!
    
    @IBOutlet weak var licensePlateLabel: PaddingLabel!
    
    var delegate: VisionViewDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateIn()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Hero.shared.delegate = nil
    }
    
    override func setupUI() {
        super.setupUI()
        
        Hero.shared.delegate = self
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupInstructionLabel()
    }
    
    private func setupInstructionLabel() {
        instructionLabel.layer.cornerRadius = 6
        instructionLabel.layer.masksToBounds = true
    }
    
    private func animateIn() {
        UIView.animate(withDuration: 1) { [weak self] in
            
            self?.visionView.backgroundColor = K.colors.backgroundDark
            
        } completion: { [weak self] didComplete in
            guard didComplete else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.instructionLabel.isHidden = false
                self?.instructionLabel.fadeIn()
            }
        }

    }
    
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.heroNavigationAnimationType = .slide(direction: .down)
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {
        //toggle flash
    }
    
    @IBAction func addFromDeviceButtonPressed(_ sender: UIButton) {
        
    }
    
}

extension VisionViewController: HeroTransitionDelegate, HeroViewControllerDelegate {
    func heroTransition(_ hero: HeroTransition, didUpdate state: HeroTransitionState) {}
    func heroTransition(_ hero: HeroTransition, didUpdate progress: Double) {}
    
    func heroDidEndAnimatingTo(viewController: UIViewController) {
        if viewController is MainViewController {
            delegate?.visionViewDidCancelSearch()
        }
    }
    
}

