//
//  VisionAlgorithmViewController.swift
//  Car Data
//
//  Created by itay gervash on 21/06/2022.
//

import UIKit
import Hero

class VisionAlgorithmViewController: CDViewController {
    
    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet weak var sliderCard: UIView!
    @IBOutlet weak var slider: UISlider!
    
    private var initialSliderValue: Float = 0
    
    private var algorithmType: VisionAlgorithmType = UserDefaultsManager.main.visionAlgorithmType() {
        didSet {
            Def.main.updateAlgorithmType(to: algorithmType)
        }
    }
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .left)
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupHeader()
        setupSliderCard()
        setupSlider()
    }
    
    private func setupHeader() {
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerDidTap(_:)))
        
        headerStackView.addGestureRecognizer(tapGR)
    }
    
    private func setupSliderCard() {
        sliderCard.layer.cornerRadius = 13
        sliderCard.layer.masksToBounds = true
    }
    
    private func setupSlider() {
        
        slider.value = Float(UserDefaultsManager.main.visionAlgorithmType().rawValue)
        initialSliderValue = slider.value
    }
    
    //MARK: - IBActions

    @IBAction func headerBackButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sliderDidChangeValue(_ sender: UISlider) {
        
        sender.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 2) { [weak self] in
            guard let self = self else { return }
            
            if abs(sender.value - self.initialSliderValue) > 0.25,
               let newAlgorithmType = VisionAlgorithmType(rawValue: Int(sender.value.rounded())) {
                
                sender.value = sender.value.rounded()
                self.algorithmType = newAlgorithmType
            } else {
                sender.value = self.initialSliderValue
            }
            
        } completion: { [weak self] finish in
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            self?.initialSliderValue = sender.value
            sender.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - Selectors
    
    @objc private func headerDidTap(_ sender: UITapGestureRecognizer) {

        if sender.location(in: headerStackView).x > headerStackView.frame.maxX * 0.6 {
            navigationController?.popViewController(animated: true)
        }
        

    }
}
