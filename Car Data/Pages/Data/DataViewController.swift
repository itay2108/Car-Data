//
//  DataViewController.swift
//  Car Data
//
//  Created by itay gervash on 03/06/2022.
//

import UIKit
import Hero
import simd

class DataViewController: CDViewController, AdDisplayable {
    
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
    
    var isPresentingNewSearch: Bool = false
    var shouldPresentAdOnAppear: Bool = false {
        didSet {
            if hasPremium && shouldPresentAdOnAppear {
                shouldPresentAdOnAppear = false
            }
        }
    }
    
    override var allowsSwipeLeftToPopViewController: Bool {
        return true
    }
    
    override var popsToMainVC: Bool {
        return isPresentingNewSearch
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
        
        if shouldPresentAdOnAppear {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.showAdViewController()
                self?.shouldPresentAdOnAppear = false
            }
        }
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
        
        guard let data = data else {
            disabilityLabel.isHidden = false
            return
        }
        
        disabilityLabel.text = data.hasDisablity ? HasDisabilityLabel.yes.rawValue : HasDisabilityLabel.no.rawValue

        disabilityStackView.hero.modifiers = [.delay(0.6), .fade, .translate(x: 0, y: 20, z: 0)]
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(disabilityLabelDidLongPress(_:)))
        longPressGR.minimumPressDuration = 0.4
        
        disabilityStackView.addGestureRecognizer(longPressGR)
    }
    
    private func setupTableView() {
        dataTableView.delegate = self
        dataTableView.dataSource = self
        
        dataTableView.register(UINib(nibName: DataSectionTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: DataSectionTableViewCell.reuseID)
        
        dataTableView.backgroundColor = .clear
        dataTableView.layer.cornerRadius = 13
        dataTableView.layer.masksToBounds = true
        
        dataTableView.decelerationRate = .fast
        
        dataTableView.hero.modifiers = [.fade, .delay(0.166), .translate(x: 0, y: 20, z: 0), .duration(0.533)]
        
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
    
    @objc private func disabilityLabelDidLongPress(_ sender: UILongPressGestureRecognizer) {
        
        guard let data = data else {
            return
        }
        
        let baseMessage = "לפי קאר דאטה, לרכב מספר"
        let licencePlate = LicensePlateManager.maskToLicensePlateFormat(String(describing:  data.baseData.plateNumber))
        let hasDisability = data.hasDisablity ? HasDisabilityLabel.yes : HasDisabilityLabel.no
        
        UIPasteboard.general.string = baseMessage + " " + licencePlate + " " + hasDisability.pasteboardMessage()
        
        toast(message: "הערך הועתק בהצלחה", feedbackType: .rigid, timeoutStyle: .fast)
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
                       numberOfCells: data.allSections.count)
            
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
                                                       height: view.frame.height * 0.27))
        
        licensePlateLabel.center = CGPoint(x: view.center.x, y: view.center.y + logoView.frame.height / 4)
        
        licensePlateLabel.backgroundColor = K.colors.accents.yellow
        licensePlateLabel.textColor = K.colors.text.dark
        
        licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(plateNumber)
        licensePlateLabel.textAlignment = .center
        licensePlateLabel.font = Rubik.semiBold.ofSize(view.frame.height * 0.57)
        licensePlateLabel.adjustsFontSizeToFitWidth = true
        
        licensePlateLabel.leftInset = 20
        licensePlateLabel.rightInset = 20
        
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
        return data?.allSections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DataSectionTableViewCell.reuseID) as? DataSectionTableViewCell,
              let source = data?.allSections[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: source, isLast: indexPath.row == data?.allSections.count)
        cell.delegate = self
        cell.parameterTableView.reloadData()
        
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

extension DataViewController: DataSectionTableViewCellDelegate {
  
    func didLongPress(parameterCellOf type: CDParameter) {
        
        if let messageSuffix = type.asCopyMessage(),
            let plateNumber = licensePlateNumber {
            let prefix = "בדקתי בקאר דאטה על רכב מספר \(plateNumber), ו"
            
            UIPasteboard.general.string = prefix + messageSuffix
            
            toast(message: "הערך הועתק בהצלחה", feedbackType: .success, timeoutStyle: .fast)
        }
    }
    
    func didLongPress(parameterCellWith value: String) {
        UIPasteboard.general.string = value
        
        toast(message: "הערך הועתק בהצלחה", feedbackType: .rigid, timeoutStyle: .fast)
    }
    

}
