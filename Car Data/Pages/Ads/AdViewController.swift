//
//  AdViewController.swift
//  Car Data
//
//  Created by itay gervash on 19/07/2022.
//

import UIKit

class AdViewController: CDViewController {

    //Views
    
    @IBOutlet weak var dismissButton: UIButton!
    
    @IBOutlet weak var countdownContainer: UIView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var adContainer: UIView!
    
    //Parameters
    
    private var countdownTimer: Timer?
    private var labelUpdateTimer: Timer?
    
    private var waitingTime: TimeInterval = 5.0 {
        didSet {
            countdownLabel.text = String(describing: Int(waitingTime))
        }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fireCountdownTimers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .down)
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupAdView()
        setupCountownView()
    }
    
    private func setupAdView() {
        //
    }
    
    private func setupCountownView() {
        countdownContainer.isHidden = false
        
        countdownContainer.layer.masksToBounds = true
        countdownContainer.layer.cornerRadius = countdownContainer.frame.height / 2
        
        countdownLabel.text = String(describing: Int(waitingTime))
    }
    
    private func fireCountdownTimers() {
        countdownTimer = Timer.scheduledTimer(timeInterval: waitingTime, target: self, selector: #selector(allowDismiss), userInfo: nil, repeats: false)
        
        labelUpdateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerView), userInfo: nil, repeats: true)
    }
    
    //MARK: - Selectors
    
    @objc private func allowDismiss() {
        
        labelUpdateTimer?.invalidate()
        labelUpdateTimer = nil
        
        countdownContainer.fadeOut(0.25, delay: 0) { [weak self] finish in
            self?.countdownContainer.isHidden = true
            self?.countdownContainer.alpha = 1
            
            self?.waitingTime = 5.0
            self?.dismissButton.fadeIn()
        }
    }
    
    @objc private func updateTimerView() {
    
        waitingTime -= 1
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        dismiss()
    }
}
