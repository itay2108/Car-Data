//
//  DataViewController.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit
import Hero
import simd

class DataViewController: CDViewController {
    
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var licensePlateLabel: PaddingLabel!
    @IBOutlet weak var licensePlateLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var disabilityStackView: UIStackView!
    @IBOutlet weak var disabilityLabel: UILabel!
    
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var dataTableViewTopAnchor: NSLayoutConstraint!
    
    var data: CarData?
    
    private var defaultLicensePlateTopConstant: CGFloat = 96
    private var defaultDataTableTopConstant: CGFloat = 72
    
    private var initialBackSwipePoint: CGPoint?
    
    private var quarterOfScreenWidth: CGFloat {
        return view.frame.width / 4
    }
    
    private var sixthOfScreenHeight: CGFloat {
        return view.frame.height / 6
    }
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        licensePlateLabelTopAnchor.constant = self.view.frame.height * 0.1
        dataTableViewTopAnchor.constant = licensePlateLabelTopAnchor.constant * 0.75
        
        defaultLicensePlateTopConstant = licensePlateLabelTopAnchor.constant
        defaultDataTableTopConstant = dataTableViewTopAnchor.constant
        
        updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.heroNavigationAnimationType = .slide(direction: .left)
        
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupHeader()
        setupMainView()
        setupLicensePlateLabel()
        setupDisabilityLabel()
        setupTableView()
    }
    
    private func setupHeader() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerTitleDidTap(_:)))
        headerTitleLabel.addGestureRecognizer(tapGR)
        headerTitleLabel.isUserInteractionEnabled = true
    }
    
    private func setupMainView() {
        let swipeGR = UIPanGestureRecognizer(target: self, action: #selector(screenDidSwipeToDismiss(_:)))
        view.addGestureRecognizer(swipeGR)
    }
    
    private func setupLicensePlateLabel() {
        
        licensePlateLabel.layer.cornerRadius = 13
        licensePlateLabel.layer.masksToBounds = true
        
        if let plateNumber = data?.id {
            licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(String(plateNumber))
        } else {
            licensePlateLabel.text = "-"
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(licensePlateLabelDidTap(_:)))
        
        licensePlateLabel.isUserInteractionEnabled = true
        licensePlateLabel.addGestureRecognizer(tapGR)
    }
    
    private func setupDisabilityLabel() {
        if let data = data {
            disabilityLabel.text = data.hasDisablity ? HasDisabilityLabel.yes.rawValue : HasDisabilityLabel.no.rawValue
        } else {
            disabilityLabel.isHidden = true
        }
        
    }
    
    private func setupTableView() {
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        dataTableView.register(UINib(nibName: DataSectionTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: DataSectionTableViewCell.reuseID)
        
        dataTableView.backgroundColor = .clear
        dataTableView.layer.cornerRadius = 13
        dataTableView.layer.masksToBounds = true
        
        dataTableView.decelerationRate = .fast
        
    }
    
    private func dismiss(withDelay delay: TimeInterval = 0) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.licensePlateLabel.heroID = nil
            
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    //MARK: - IB Methods
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(withDelay: 0.1)
    }
    
    //MARK: - Selectors
    
    @objc private func headerTitleDidTap(_ sender: UITapGestureRecognizer) {
        dismiss(withDelay: 0.1)
    }
    
    @objc private func screenDidSwipeToDismiss(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            initialBackSwipePoint = sender.location(in: view)
        }
        
        if sender.state == .changed || sender.state == .ended {
            let currentPoint = sender.location(in: view)
            
            guard let initialPoint = initialBackSwipePoint else {
                return
            }
            
            
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
    
    @objc private func licensePlateLabelDidTap(_ sender: UITapGestureRecognizer) {
        
        dataTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
}

extension DataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataSectionTableViewCell.reuseID) as? DataSectionTableViewCell,
              let source = data?.sections[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: source)
        
        return cell
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == dataTableView {
            
            licensePlateLabelTopAnchor.constant = defaultLicensePlateTopConstant - (scrollView.contentOffset.y / 4)
            
            dataTableViewTopAnchor.constant = defaultDataTableTopConstant - (scrollView.contentOffset.y / 8)
            
            if licensePlateLabelTopAnchor.constant < 1 {
                licensePlateLabelTopAnchor.constant = 1
            }
            
            if dataTableViewTopAnchor.constant < 18 {
                dataTableViewTopAnchor.constant = 18
            }
            
            headerTitleLabel.isHidden = licensePlateLabelTopAnchor.constant < 8
            
            let fontModifier: CGFloat = 0.5 + ((0.5 / defaultLicensePlateTopConstant) * licensePlateLabelTopAnchor.constant)
            
            licensePlateLabel.font = Rubik.semiBold.ofSize(36 * fontModifier > headerTitleLabel.font.pointSize + 1 ? 36 * fontModifier : headerTitleLabel.font.pointSize + 2)
            
            let fadeModifier: CGFloat = (1 / defaultLicensePlateTopConstant) * licensePlateLabelTopAnchor.constant
            
            licensePlateLabel.backgroundColor = K.colors.accents.yellow.withAlphaComponent(fadeModifier)
            
            disabilityStackView.alpha = pow(fadeModifier, 8)
            
            updateViewConstraints()
        }
    }
    
}
