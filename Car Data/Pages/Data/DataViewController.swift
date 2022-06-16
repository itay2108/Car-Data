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
    
    private var blurView: UIVisualEffectView?
    
    var data: CarData?
    
    private var defaultLicensePlateTopConstant: CGFloat = 96
    private var defaultDataTableTopConstant: CGFloat = 72
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    override var popsToMainVC: Bool {
        return true
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
    
    override func viewWillDisappear(_ animated: Bool) {
        licensePlateLabel.heroID = nil
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupHeader()
        setupLicensePlateLabel()
        setupDisabilityLabel()
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
    
    //MARK: - IB Methods
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(withDelay: 0.1)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        super.dismiss(animated: flag, completion: completion)
        
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        guard let licensePlate = licensePlateNumber else {
            presentErrorAlert(with: CDError.pdfNoData)
            return
        }
        
        blurView = blurView()
        
        if let blurView = blurView {
            view.addSubview(blurView)
            blurView.fadeIn()
        }
        
        
        blurView?.isUserInteractionEnabled = false
        
        if let urlPath = captureDataToPDF() {
            let message = "בדקתי בקאר דאטה על רכב מספר \(licensePlate), הנה הנתונים שלו."
            let activityContoller = UIActivityViewController(activityItems: [message, urlPath], applicationActivities: nil)
            
            activityContoller.completionWithItemsHandler = { [weak self] (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                self?.blurView?.fadeOut()
                self?.blurView = nil
                
                do {
                    try CDURLManager.deleteFile(from: urlPath)
                } catch {
                    self?.presentErrorAlert(with: error)
                }

            }
            
            present(activityContoller, animated: true)
            
        } else {
            blurView?.fadeOut()
            blurView = nil
        }
    }
    //MARK: - Selectors
    
    @objc private func headerTitleDidTap(_ sender: UITapGestureRecognizer) {
        dismiss(withDelay: 0.1)
    }
    
    @objc private func licensePlateLabelDidTap(_ sender: UITapGestureRecognizer) {
        
        dataTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    //MARK: - Sharing Methods
    
    private func captureDataToPDF() -> URL? {
        
        guard let data = data,
              let plateNumber = licensePlateNumber else {
            return nil
        }
        
        do {
            let pathForPDF = try render(pdfWithName: "נתונים לרכב \(data.extraData?.manufacturer ?? "") \(data.baseData.model ?? "") - \(plateNumber)",
                       withHeader: pdfHeaderImage(with: plateNumber),
                       from: dataTableView,
                       numberOfCells: data.sections.count)
            
            return pathForPDF
        } catch {
            presentErrorAlert(with: error)
            return nil
        }
    }
    
    private func pdfHeaderImage(with plateNumber: String) -> UIImage {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: dataTableView.frame.width, height: view.frame.height / 4))
        view.backgroundColor = K.colors.background
        
        let logoView = UIImageView(frame: CGRect(x: view.frame.maxX - (view.frame.width / 4) - 16, y: 16, width: view.frame.width / 4, height: view.frame.height / 6))
        logoView.image = UIImage(named: "cd-logo-label")
        
        logoView.contentMode = .scaleAspectFit

        view.addSubview(logoView)

        
        let licensePlateLabel = PaddingLabel(frame:
                                                CGRect(x: 0,
                                                       y: 0,
                                                       width: view.frame.width * 0.5,
                                                       height: view.frame.height * 0.3))
        
        licensePlateLabel.center = CGPoint(x: view.center.x, y: view.center.y + logoView.frame.height / 4)
        
        licensePlateLabel.backgroundColor = K.colors.accents.yellow
        licensePlateLabel.textColor = K.colors.text.dark
        
        licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(plateNumber)
        licensePlateLabel.textAlignment = .center
        licensePlateLabel.font = Rubik.semiBold.ofSize(view.frame.height * 0.38)
        licensePlateLabel.adjustsFontSizeToFitWidth = true
        
        licensePlateLabel.leftInset = 24
        licensePlateLabel.rightInset = 24
        
        licensePlateLabel.layer.masksToBounds = true
        licensePlateLabel.layer.cornerRadius = 13
        
        view.addSubview(licensePlateLabel)
        
        let disabilityLabelInternal = UILabel(frame: CGRect(x: 0, y: 0, width: licensePlateLabel.frame.width / 2, height: 16))
        
        disabilityLabelInternal.font = Rubik.medium.ofSize(licensePlateLabel.font.pointSize / 4)
        disabilityLabelInternal.adjustsFontSizeToFitWidth = true
        disabilityLabelInternal.textColor = K.colors.text.light
        
        disabilityLabelInternal.text = self.disabilityLabel.text
        disabilityLabelInternal.contentMode = .center
        
        disabilityLabelInternal.textAlignment = .center
        view.addSubview(disabilityLabelInternal)
        
        disabilityLabelInternal.center = CGPoint(x: view.center.x, y: view.frame.maxY - 24)
        
        let disabilityIcon = UIImageView(frame: CGRect(x: disabilityLabelInternal.frame.maxX + 6, y: disabilityLabelInternal.frame.minY + 2, width: disabilityLabelInternal.frame.height / 1.25, height: disabilityLabelInternal.frame.height / 1.25))
        
        disabilityIcon.image = UIImage(named: "cd-wheelchair")
        disabilityIcon.contentMode = .scaleAspectFit
        
        view.addSubview(disabilityIcon)
        
        return view.asImage()
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
