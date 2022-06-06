//
//  DataViewController.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit
import Hero

class DataViewController: CDViewController {

    @IBOutlet weak var headerTitleLabel: UILabel!
    
    @IBOutlet weak var licensePlateLabel: PaddingLabel!
    @IBOutlet weak var licensePlateLabelTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet weak var dataTableViewTopAnchor: NSLayoutConstraint!
    
    var data: CarData?
    
    private var defaultLicensePlateTopConstant: CGFloat = 96
    private var defaultDataTableTopConstant: CGFloat = 72
    
    //MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        licensePlateLabelTopAnchor.constant = self.view.frame.height * 0.125
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
        setupLicensePlateLabel()
        setupTableView()
    }
    
    private func setupHeader() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(headerTitleDidTap(_:)))
        headerTitleLabel.addGestureRecognizer(tapGR)
        headerTitleLabel.isUserInteractionEnabled = true
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
    
    private func setupTableView() {
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        dataTableView.register(UINib(nibName: DataSectionTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: DataSectionTableViewCell.reuseID)
        
        dataTableView.backgroundColor = .clear
        dataTableView.layer.cornerRadius = 13
        dataTableView.layer.masksToBounds = true
        
        dataTableView.decelerationRate = .fast

    }
    
    private func dismiss() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.licensePlateLabel.heroID = nil
            
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    //MARK: - IB Methods

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss()
    }
    
    @objc private func headerTitleDidTap(_ sender: UITapGestureRecognizer) {
        dismiss()
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
            print(scrollView.contentOffset.y)
            
            licensePlateLabelTopAnchor.constant = defaultLicensePlateTopConstant - (scrollView.contentOffset.y / 4)
            
            dataTableViewTopAnchor.constant = defaultDataTableTopConstant - (scrollView.contentOffset.y / 8)
            
            if licensePlateLabelTopAnchor.constant < 0 {
                licensePlateLabelTopAnchor.constant = 0
            }
            
            if dataTableViewTopAnchor.constant < 18 {
                dataTableViewTopAnchor.constant = 18
            }
            
            headerTitleLabel.isHidden = licensePlateLabelTopAnchor.constant == 0
            
            let fontModifier: CGFloat = 0.5 + ((0.5 / defaultLicensePlateTopConstant) * licensePlateLabelTopAnchor.constant)
            
            licensePlateLabel.font = Rubik.semiBold.ofSize(36 * fontModifier > headerTitleLabel.font.pointSize + 1 ? 36 * fontModifier : headerTitleLabel.font.pointSize + 2)
            
            let backgroundModifier: CGFloat = (1 / defaultLicensePlateTopConstant) * licensePlateLabelTopAnchor.constant
            
            licensePlateLabel.backgroundColor = K.colors.accents.yellow.withAlphaComponent(backgroundModifier)
            
            updateViewConstraints()
        }
    }
    
}
