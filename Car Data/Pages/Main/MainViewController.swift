//
//  ViewController.swift
//  Car Data
//
//  Created by itay gervash on 31/05/2022.
//

import UIKit
import Hero

final class MainViewController: CDViewController, CarDataPresentable {
    
    @IBOutlet weak var licensePlateTextFieldContainer: UIView!
    @IBOutlet weak var licensePlateTextField: UITextField!
    @IBOutlet weak var licensePlateTextFieldClearButton: UIButton!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchButtonBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var mainContainerCenterYAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var logoTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var logoHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var premiumLogoView: UIImageView!
    
    @IBOutlet weak var cameraSearchActionView: UIView!
    @IBOutlet weak var cameraSearchActionViewTitleLabel: UILabel!
    @IBOutlet weak var textFieldSearchActionView: UIView!
    @IBOutlet weak var textFieldSearchActionViewTitleLabel: PaddingLabel!
    
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var searchHistoryTableViewHeader: UIView!
    @IBOutlet weak var tableViewEmptyPlaceHolder: UIImageView!
    @IBOutlet weak var searchHistoryTableViewTitleLabel: UILabel!
    @IBOutlet weak var searchHistoryShowAllButton: UIButton!
    
    @IBOutlet weak var searchHistoryTableViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var searchHistoryTableViewShadowView: UIView!
    
    @IBOutlet weak var preferencesButton: UIButton!
    
    @IBOutlet weak var cameraTriggerContainer: UIView!
    
    //MARK: - Parameters
    
    private var keyboardFrameHeight: CGFloat?
    
    private var initialMainContainerPanOffest: CGFloat = 0

    private var isPresentingLicensePlate: Bool = false
    var shouldStopPresentingLicensePlate: Bool = false
    
    var isReturningFromLoadWithError: Bool = false
    
    var recentDataRecords: [DataRecordPreview] {
        let validRecords = RealmManager.fetch(recordsOfType: DataRecordPreview.self).sorted(by: { $1.date < $0.date })
        
        tableViewEmptyPlaceHolder.isHidden = validRecords.count > 0
        searchHistoryShowAllButton.isHidden = validRecords.count <= 5
        
        return Array(validRecords.prefix(5))
    }
    
    //MARK: - Programmatic views
    
    private lazy var focusView: UIView = {
        let focusView = UIView()
        focusView.backgroundColor = .black.withAlphaComponent(0.7)
        
        focusView.translatesAutoresizingMaskIntoConstraints = false
        
        let dismissGR = UITapGestureRecognizer(target: self, action: #selector(focusViewGRDidTrigger(_:)))
        let panDismissGR = UIPanGestureRecognizer(target: self, action: #selector(focusViewGRDidTrigger(_:)))
        
        focusView.addGestureRecognizer(dismissGR)
        focusView.addGestureRecognizer(panDismissGR)
        
        return focusView
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableViewEmptyPlaceHolder.isHidden = recentDataRecords.count > 0
        
        if !isReturningFromLoadWithError {
            searchHistoryTableView.hero.modifiers = [.fade, .delay(0.166), .translate(x: 0, y: 20, z: 0), .duration(0.533)]

            searchHistoryTableViewShadowView.hero.modifiers = [.fade, .delay(0.166), .translate(x: 0, y: 30, z: 0), .duration(0.7)]
            
            if !tableViewEmptyPlaceHolder.isHidden {
                tableViewEmptyPlaceHolder.hero.modifiers = [.fade, .delay(0.166), .translate(x: 0, y: 30, z: 0), .duration(0.7)]
            }
        }

        
        searchHistoryTableView.reloadData()
        
        updateLogoView()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.heroNavigationAnimationType = .fade
        
        licensePlateTextField.attributedPlaceholder =
        NSAttributedString(string: "הקלד מספר רכב", attributes: [NSAttributedString.Key.foregroundColor: K.colors.text.dark.withAlphaComponent(0.33)])
        licensePlateTextField.heroID = "licensePlate"

        if shouldStopPresentingLicensePlate {
            leaveSearchScene()
        }

        if mainContainerCenterYAnchor.constant != 0 && !isReturningFromLoadWithError {
            reCenterMainContainer(animated: false)
        }
        
        if UserDefaultsManager.main.numberOfSearches() > 10, RNG.probability(of: 7), !isPresentingLicensePlate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.66) { [weak self] in
                
                guard self?.mainContainerCenterYAnchor.constant == 0 else {
                    return
                }
                
                PurchaseManager.main.requestAppstoreReview()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        licensePlateTextField.attributedPlaceholder = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setuplicensePlateTextField()
        setupMainContainer()
        
        updateViewConstraints()
    }
    
    
    
    override func setupConstraints() {
        super.setupConstraints()
        
        logoTopAnchor.constant = (window?.safeAreaInsets.top ?? 0) + 16
        searchHistoryTableViewBottomAnchor.constant = (window?.safeAreaInsets.bottom ?? 0) + 16
        
        logoHeightAnchor.constant *= heightModifier
    }
    
    private func setuplicensePlateTextField() {
        
        licensePlateTextField.delegate = self
        
        licensePlateTextField.addTarget(self, action: #selector(updateLicencePlateTextField(_:)), for: .editingChanged)
        
        licensePlateTextFieldClearButton.isHidden = true
        
        licensePlateTextField.attributedPlaceholder =
        NSAttributedString(string: licensePlateTextField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: K.colors.text.dark.withAlphaComponent(0.33)])
        
        licensePlateTextField.font = Rubik.semiBold.ofSize(36 * heightModifier)
        
    }
    
    private func setupMainContainer() {
        mainContainer.addGestureRecognizer(mainContainerPanGR())
        
        setupFocusView()
        
        setupActionViews()
        setupSearchHistoryTableView()
        setupTableViewEmptyPlaceHolder()
    }
    
    private func setupActionViews() {
        let cameraTapGR = UITapGestureRecognizer(target: self, action: #selector(cameraActionViewDidTap(_:)))
        
        cameraSearchActionView.addGestureRecognizer(cameraTapGR)
        cameraSearchActionView.addGestureRecognizer(mainContainerPanGR())
        cameraSearchActionViewTitleLabel.font = Rubik.medium.ofSize(19 * heightModifier)
        
        let textFieldSearchTapGR = UITapGestureRecognizer(target: self, action: #selector(textfieldActionViewDidTap(_:)))
        
        textFieldSearchActionView.addGestureRecognizer(textFieldSearchTapGR)
        textFieldSearchActionView.addGestureRecognizer(mainContainerPanGR())
        
        textFieldSearchActionViewTitleLabel.layer.cornerRadius = 6
        textFieldSearchActionViewTitleLabel.layer.masksToBounds = true
        textFieldSearchActionViewTitleLabel.font = Rubik.medium.ofSize(19 * heightModifier)
        
    }
    
    private func setupFocusView() {
        mainContainer.addSubview(focusView)
        
        focusView.centerXAnchor.constraint(equalTo: mainContainer.centerXAnchor).isActive = true
        focusView.centerYAnchor.constraint(equalTo: mainContainer.centerYAnchor).isActive = true
        focusView.heightAnchor.constraint(equalTo: mainContainer.heightAnchor).isActive = true
        focusView.widthAnchor.constraint(equalTo: mainContainer.widthAnchor).isActive = true
        
        focusView.alpha = 0
    }
    
    private func setupSearchHistoryTableView() {
        
        searchHistoryTableView.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 22, right: 0)
        
        searchHistoryTableView.layer.cornerRadius = 13
        searchHistoryTableView.layer.masksToBounds = true

        searchHistoryTableView.backgroundColor = .white
        searchHistoryTableView.backgroundView?.backgroundColor = .white
        
        searchHistoryTableView.delegate = self
        searchHistoryTableView.dataSource = self
        
        searchHistoryTableView.register(UINib(nibName: SearchHistoryTableViewCell.reuseID, bundle: nil), forCellReuseIdentifier: SearchHistoryTableViewCell.reuseID)
        
        
        searchHistoryTableViewTitleLabel.font = Rubik.regular.ofSize(18 * heightModifier)
        searchHistoryShowAllButton.titleLabel?.font = Rubik.regular.ofSize(13 * heightModifier)
        
        //shadow view setup
        
        searchHistoryTableViewShadowView.layer.shadowColor = K.colors.accents.dark.cgColor
        searchHistoryTableViewShadowView.layer.shadowOpacity = 0.25
        searchHistoryTableViewShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        searchHistoryTableViewShadowView.layer.shadowRadius = 20 * widthModifier
        
    }
    
    private func setupTableViewEmptyPlaceHolder() {
        tableViewEmptyPlaceHolder.isHidden = recentDataRecords.count > 0
    }
    
    
    private func reCenterMainContainer(animated: Bool, duration: TimeInterval = 0.5, _ completion: (()->Void)? = nil) {
        mainContainerCenterYAnchor.constant = 0
        
        if animated {
            UIView.animate(withDuration: duration) { [weak self] in
                self?.view.layoutIfNeeded()
            } completion: { complete in
                completion?()
            }
            
        } else {
            view.layoutIfNeeded()
            completion?()
        }
        
    }
    
    private func updateLogoView() {
        logoView.isHidden = hasPremium
        premiumLogoView.isHidden = !hasPremium
    }
    
    private func beginSearchScene() {
        insertFocusView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.licensePlateTextField.becomeFirstResponder()
        }
    }
    
    private func beginVisionScene() {
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .up)
        
        let destination = VisionViewController()
        destination.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.066) { [weak self] in
            self?.navigationController?.pushViewController(destination, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                self?.reCenterMainContainer(animated: false)
            }
        }
 
    }
    
    private func leaveSearchScene() {
        reCenterMainContainer(animated: true) { [weak self] in
            self?.licensePlateTextField.text = nil
        }
        
        dismissFocusView()
        
        shouldStopPresentingLicensePlate = false
    }
    
    private func insertFocusView() {
        guard !isPresentingLicensePlate else { return }
        
        focusView.fadeIn()
        
        isPresentingLicensePlate = true
    }
    
    private func dismissFocusView() {
        guard isPresentingLicensePlate else { return }
        
        focusView.fadeOut()
        
        isPresentingLicensePlate = false
    }
    
    private func mainContainerPanGR() -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: self, action: #selector(mainContainerPanGRDidTrigger(_:)))
    }
    
    //MARK: - IB Methods
    
    @IBAction func licensePlateTextFieldClearButtonTapped(_ sender: UIButton) {
        
        licensePlateTextField.text = nil
        sender.isHidden = true
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
        if let input = licensePlateTextField.text,
           LicensePlateManager.licensePlateIsValid(input) {
            licensePlateTextField.resignFirstResponder()
            
            licensePlateNumber = LicensePlateManager.cleanLicensePlateNumber(from: input).trimming(character: "0", from: .beginning)
            
            searchHistoryTableView.hero.modifiers = []
            searchHistoryTableViewShadowView.hero.modifiers = []
            tableViewEmptyPlaceHolder.hero.modifiers = []
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [unowned self] in
                
                performSegue(withIdentifier: K.segues.mainStoryboard.mainToLoadResult, sender: self)
            }
            
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        
    }
    
    @IBAction func preferencesButtonTapped(_ sender: UIButton) {
        
        guard let destination = K.storyBoards.preferencesStoryBoard.instantiateViewController(withIdentifier: K.viewControllerIDs.preferencesVC) as? PreferencesViewController else {
            presentErrorAlert(with: CDError.unknownError)
            return
        }
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
        
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @IBAction func searchHistoryShowAllButtonPressed(_ sender: UIButton) {
        
        guard hasPremium else {
            showPremiumViewController()
            return
        }
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
        
        performSegue(withIdentifier: K.segues.mainStoryboard.mainToSearchHistory, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let destination = segue.destination as? LoadResultViewController,
           let licensePlateNumber = licensePlateNumber {
            destination.licensePlateNumber = licensePlateNumber
            destination.delegate = self
        }
        
        if let destination = segue.destination as? SearchHistoryViewController {

            destination.cdTableViewRowHeight = cdTableViewRowHeight
        }
    }
    
    //MARK: - Selectors
    
    @objc private func focusViewGRDidTrigger(_ sender: UITapGestureRecognizer) {
        licensePlateTextField.resignFirstResponder()
        
        if sender.state != .failed && sender.state != .cancelled {
            focusView.fadeOut()
            
            reCenterMainContainer(animated: true, duration: 0.5) { [weak self] in
                self?.licensePlateTextField.text = nil
                self?.isPresentingLicensePlate = false
            }
        }
    }
    
    @objc private func mainContainerPanGRDidTrigger(_ sender: UIPanGestureRecognizer) {
        
        guard let view = sender.view, !isPresentingLicensePlate else {
            return
        }
        
        //define limit depending on initial position
        let positiveLimit = licensePlateTextFieldContainer.frame.height
        
        let negativeLimit = -(cameraTriggerContainer.frame.height)
        
        if sender.state == .began {
            
            if mainContainerCenterYAnchor.constant != 0 {
                reCenterMainContainer(animated: true)
                sender.finishCurrentGesture()
            }
            
            licensePlateTextField.resignFirstResponder()
        }
        
        if sender.state == .changed {
            let yTranslation = sender.translation(in: view).y

            if yTranslation >= positiveLimit {
                mainContainerCenterYAnchor.constant = positiveLimit
            } else if yTranslation <= negativeLimit {
                mainContainerCenterYAnchor.constant = negativeLimit
            } else {
                mainContainerCenterYAnchor.constant = yTranslation
            }
            
            updateViewConstraints()
            
            //define what happens when dragging past limit
            if yTranslation >= positiveLimit || yTranslation <= negativeLimit  {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                sender.finishCurrentGesture()
                
                if mainContainerCenterYAnchor.constant == -cameraTriggerContainer.frame.height {
                    //camera trigger
                    beginVisionScene()
                    
                } else if mainContainerCenterYAnchor.constant == licensePlateTextFieldContainer.frame.height {
                    //textfield trigger
                    beginSearchScene()
                }
            }
            
        } else if sender.state == .ended {
            if mainContainerCenterYAnchor.constant != negativeLimit && mainContainerCenterYAnchor.constant != positiveLimit {
                
                reCenterMainContainer(animated: true)
                
            }
        }
        
        
    }
    
    @objc private func cameraActionViewDidTap(_ sender: UITapGestureRecognizer) {
        
        guard mainContainerCenterYAnchor.constant == 0 else { return }
        
        let offset = cameraTriggerContainer.frame.height
        
        mainContainerCenterYAnchor.constant -= offset
        
        UIView.animate(withDuration: 0.33) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: {  [weak self] finish in
            
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            //Open Camera
            self?.beginVisionScene()
        }
    }
    
    @objc private func textfieldActionViewDidTap(_ sender: UITapGestureRecognizer) {
        
        guard mainContainerCenterYAnchor.constant == 0 else { return }
        
        let offset = licensePlateTextFieldContainer.frame.height
        
        mainContainerCenterYAnchor.constant += offset
        
        beginSearchScene()
        
        UIView.animate(withDuration: 0.33) { [weak self] in
            self?.view.layoutIfNeeded()
        } completion: {  finish in
            
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        keyboardFrameHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.height
    }
    
    @objc private func keyboardDidShow(_ notification: NSNotification) {
        
        if let keyboardFrameHeight = keyboardFrameHeight {
            searchButton.isHidden = false
            
            if searchButtonBottomAnchor.constant == 0 {
                searchButtonBottomAnchor.constant += keyboardFrameHeight + 12
            }
            
            updateViewConstraints()
            
            searchButton.fadeIn(duration: 0.16, delay: 0)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        searchButton.fadeOut(0.3, delay: 0) { [weak self] finish in
            self?.searchButton.isHidden = true
            self?.searchButtonBottomAnchor.constant = 0
        }
    }
    
    @objc private func updateLicencePlateTextField(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let formattedText = LicensePlateManager.maskToLicensePlateFormat(text)
        
        licensePlateTextField.text = formattedText
        licensePlateTextFieldClearButton.isHidden = formattedText.count == 0
        
        licensePlateNumber = nil
    }
    
    //MARK: - Observers
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == licensePlateTextField, textField.text?.count ?? 0 >= 10 {
            if let char = string.cString(using: String.Encoding.utf8) {
                let isBackSpace = strcmp(char, "\\b")
                if (isBackSpace == -92) {
                    return true
                }
            }
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let textLength = textField.text?.count,
           textLength > 0 {
            licensePlateTextFieldClearButton.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        licensePlateTextFieldClearButton.isHidden = true
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return recentDataRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchHistoryTableViewCell.reuseID) as? SearchHistoryTableViewCell,
              let record = recentDataRecords[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: record)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        cdTableViewRowHeight = (searchHistoryTableView.frame.height - searchHistoryTableViewHeader.frame.height - searchHistoryTableView.contentInset.bottom - searchHistoryTableView.contentInset.top) / 5
        return cdTableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == searchHistoryTableView,
              let recordKey = recentDataRecords[safe: indexPath.row]?.key,
              let data = RealmManager.fetch(recordOfType: DataRecord.self, withPrimaryKey: recordKey)?.data?.asCarData() else {
            return
        }
        
        licensePlateTextField.heroID = nil
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .right)
        
        presentDataVC(using: data)
    }
    
    
}

extension MainViewController: LoadResultDelegate {
    func resultLoader(didFailWith error: Error, for licensePlate: String?) {
        isReturningFromLoadWithError = true
        
        searchHistoryTableView.hero.modifiers = []
        searchHistoryTableViewShadowView.hero.modifiers = []
        tableViewEmptyPlaceHolder.hero.modifiers = []
        
        if (error as? CDError) == CDError.canceled {
            
            
            mainContainerCenterYAnchor.constant = licensePlateTextFieldContainer.frame.height
            updateViewConstraints()
            beginSearchScene()
            
            licensePlateTextField.becomeFirstResponder()
            return
        }
        
        let cancelAction = UIAlertAction(title: "ביטול", style: .cancel) { [weak self] action in
            
            self?.focusView.fadeOut()
            
            self?.reCenterMainContainer(animated: true, duration: 0.5) {
                self?.licensePlateTextField.text = nil
                self?.isPresentingLicensePlate = false
                
                self?.isReturningFromLoadWithError = false
            }

        }
        
        let retryAction = UIAlertAction(title: "ניסוי מחדש", style: .default) { [weak self] action in
            
            self?.licensePlateTextField.becomeFirstResponder()
            self?.isReturningFromLoadWithError = false
        }
        
        let errorDescription: String?
        
        if let error = error as? CDError {
            errorDescription = error.localizedDescription
        } else {
            errorDescription = error.localizedDescription
        }
        
        presentErrorAlert(with: error, withDescription: true, customDesription: errorDescription, actions: [retryAction, cancelAction])

    }
    
    func resultLoader(didReceive data: CarData) {
        leaveSearchScene()
    }
}


extension MainViewController: VisionViewDelegate {
    func visionViewDidCancelSearch() {
        reCenterMainContainer(animated: true)
    }
}
