//
//  VisionViewController.swift
//  Car Data
//
//  Created by itay gervash on 08/06/2022.
//

import UIKit
import Vision
import Hero
import AVFoundation
import NVActivityIndicatorView

protocol VisionViewDelegate {
    func visionViewDidCancelSearch()
    func visionView(didDetectPlate licensePlateNumber: String)
}

extension VisionViewDelegate {
    func visionViewDidCancelSearch() { }
    func visionView(didDetectPlate licensePlateNumber: String) { }
}


final class VisionViewController: CDViewController {

    @IBOutlet weak var visionView: LiveCameraView!
    @IBOutlet weak var visionFocusView: UIView!
    
    @IBOutlet weak var visionViewActivityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var visionViewActivityIndicatorCenterYAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var instructionLabel: PaddingLabel!
    
    @IBOutlet weak var licensePlateHeroView: UIView!
    @IBOutlet weak var licensePlateLabel: PaddingLabel!
    
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flashButtonHighlightView: UIImageView!
    
    @IBOutlet weak var addFromDeviceButton: UIButton!
    
    var delegate: VisionViewDelegate?
    
    //Live Preview Parameters
    
    private let captureSession = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: K.queueIDs.captureSession)
    
    private var captureDevice: AVCaptureDevice?
    
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataOutputQueue = DispatchQueue(label: K.queueIDs.videoOutputSession)
    
    private var bufferAspectRatio: Double!
    
    //Static Vision Parameter
    private var isDetectingFromStaticImage: Bool = false
    
    private lazy var imagePicker: UIImagePickerController = {
       return UIImagePickerController()
    }()
    
    private lazy var staticRecognitionImageView: UIImageView = {
        let imageView = UIImageView(frame: view.frame)
        imageView.center = view.center
        
        imageView.backgroundColor = .clear
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.alpha = 0.0
        
        return imageView
    }()
    
    //Vision Parameters
    
    private var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    private let visionFocusMaskLayer = CAShapeLayer()
    
    private lazy var visionBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let visionBlurView = UIVisualEffectView(effect: blurEffect)
        
        visionBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return visionBlurView
    }()
    
    private var recognitionrequest: VNRecognizeTextRequest?

    private var didDetectInitialLicensePlate: Bool = false
    
    private var timeSinceLastSampleDetection: Int = 0
    private var sampleFrequencyTimer: Timer?
    
    //vision detections that match plate rules get added to this array. when array contains enough samples, use the most frequent sample. if no frequent, use the longest sample.
    private var potentialPlateNumbers: [String] = []
    
    private var licensePlateSampleThreshold: Int = Def.main.visionAlgorithmType().sampleThreshold()
    
    //MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateIn()
        
        didDetectInitialLicensePlate = false
        potentialPlateNumbers.removeAll()
        
        addFromDeviceButton.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.imagePicker.allowsEditing = true
            
            self?.imagePicker.modalPresentationStyle = .fullScreen
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if captureSession.isRunning {
            captureSessionQueue.async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
    
    //MARK: - UI Methods
    
    override func setupViews() {
        super.setupViews()
        
        setupInstructionLabel()
        setupVisionView()
        setupLicensePlateLabel()
    }
    
    private func setupVisionView() {
        recognitionrequest = VNRecognizeTextRequest(completionHandler: handle(request:error:))
        
        visionView.session = captureSession
        
        captureSessionQueue.async { [weak self] in
            
            do {
                try self?.setupCaptureSession()
                
            }
            catch {
                self?.presentErrorAlert(with: error)
            }

            // Calculate region of interest now that the camera is setup & show instructions.
            DispatchQueue.main.async {
                self?.animateInstructionIn()
                
                self?.calculateRegionOfInterest()
            }
        }
        
        setupVisionFocusView()
    }
    
    private func setupInstructionLabel() {
        instructionLabel.layer.cornerRadius = 6
        instructionLabel.layer.masksToBounds = true
    }
    
    private func setupVisionFocusView() {
        visionFocusMaskLayer.backgroundColor = UIColor.clear.cgColor
        visionFocusMaskLayer.fillRule = .evenOdd
        visionFocusView.layer.mask = visionFocusMaskLayer
        
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(visionViewDidSwipeDown(_:)))
        swipeGR.direction = .down
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(visionViewDidPinch(_:)))
        
        visionFocusView.isUserInteractionEnabled = true
        visionFocusView.addGestureRecognizer(swipeGR)
        visionFocusView.addGestureRecognizer(pinchGR)
        
        updateVisionFocusViewCutout()
    }
    
    private func setupLicensePlateLabel() {
        licensePlateLabel.layer.cornerRadius = 13
        licensePlateLabel.layer.masksToBounds = true
    }
    
    //MARK: Animation Methods
    
    private func animateIn() {
        
        visionView.fadeIn()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.visionView.backgroundColor = K.colors.backgroundDark
            
        }
    }
    
    private func animateOut() {
        instructionLabel.isHidden = true
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .down)
        licensePlateHeroView.heroID = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.visionView.fadeOut(0.1)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    private func animatePauseSession(_ completion: (()->Void)? = nil) {
        for view in view.subviews {
            if view == visionBlurView {
                view.removeFromSuperview()
            }
        }
        
        visionViewActivityIndicator.stopAnimating()
        
        visionBlurView.frame = view.bounds
        
        view.insertSubview(visionBlurView, belowSubview: licensePlateLabel)
        
        visionBlurView.fadeIn { [weak self] in
            self?.captureSessionQueue.async {
                self?.captureSession.stopRunning()
            }
            
            self?.instructionLabel.isHidden = true
            self?.visionFocusView.isHidden = true
            completion?()
        }
    }
    
    private func animateResumeSession(_ completion: (()->Void)? = nil) {
        
        isDetectingFromStaticImage = false
        
        visionBlurView.fadeOut(0.4) { [weak self] finish in
            self?.visionBlurView.removeFromSuperview()
            
            self?.visionFocusView.fadeIn() {
                self?.instructionLabel.isHidden = false
                completion?()
            }
        }
        
        if !captureSession.isRunning {
            captureSessionQueue.async { [weak self] in
                self?.captureSession.startRunning()
            }
        }

    }
    
    private func animateSuccess(_ completion: (()->Void)? = nil) {
        
        animatePauseSession { [weak self] in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            self?.licensePlateLabel.isHidden = false
            
            self?.licensePlateLabel.fadeIn() {
                self?.licensePlateHeroView.isHidden = false
                self?.licensePlateHeroView.heroID = "licensePlateContainer"
                
                completion?()
            }
        }
        
    }
    
    private func animateInstructionIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.166) { [weak self] in
            self?.instructionLabel.isHidden = false
            self?.instructionLabel.fadeIn()
        }
    }
    
    private func animateDetectingSamplesIn() {
        DispatchQueue.main.async { [weak self] in
            self?.visionViewActivityIndicator.startAnimating()
            self?.instructionLabel.fadeOut()
        }
    }
    
    
    //MARK: - Handle License Plate Detection
    
    private func didDetect(plate licensePlateNumber: String) {
        
        DispatchQueue.main.async { [weak self] in
            self?.sampleFrequencyTimer?.invalidate()
            self?.instructionLabel.isHidden = true
            
            self?.addFromDeviceButton.isEnabled = false
        }

        
        captureSessionQueue.sync { [weak self] in
            self?.captureSession.stopRunning()
            
            DispatchQueue.main.async {
                self?.licensePlateLabel.text = LicensePlateManager.maskToLicensePlateFormat(licensePlateNumber)
                
                self?.animateSuccess() {
                    //move to LoadResults
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        self?.presentLoadResultVC(with: licensePlateNumber)
                    }
                }
            }
        }
    }
    
    private func presentLoadResultVC(with licensePlate: String) {
        guard let destination = K.storyBoards.mainStoryBoard.instantiateViewController(withIdentifier: K.viewControllerIDs.loadResult) as? LoadResultViewController else {
            return
        }
        
        destination.licensePlateNumber = licensePlate
        
        navigationController?.heroNavigationAnimationType = .fade
        
        navigationController?.pushViewController(destination, animated: true)
        
        destination.delegate = self
    }
    
    private func didDetectFirstSample() {
        guard !didDetectInitialLicensePlate else { return }
        
        didDetectInitialLicensePlate = true
        
        animateDetectingSamplesIn()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.sampleFrequencyTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countTimeBetweenSamples), userInfo: nil, repeats: true)
        }

    }
    
    @objc func countTimeBetweenSamples() {
        timeSinceLastSampleDetection += 1
        
        if timeSinceLastSampleDetection >= 3, instructionLabel.alpha == 0 {
            animateInstructionIn()
            visionViewActivityIndicator.stopAnimating()
        }
    }
    
    //Static License Plate Detection
    
    private func didSelect(imageForPlateRecognition image: UIImage) {
        
        potentialPlateNumbers.removeAll()
        isDetectingFromStaticImage = true
        
        do {
            try recognizeLicensePlateNumber(in: image.cgImage)
        } catch {
            presentErrorAlert(with: error)
        }
    }
    
    
    //MARK: - IB Actions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        captureSessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
        
        animateOut()
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {
        guard captureSession.isRunning else { return }
        
        do {
            let isFlashOn = try toggleFlash()
            
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            let tint = isFlashOn ? K.colors.text.dark : K.colors.background
            
            flashButton.tintColor = tint
            
            if isFlashOn {
                flashButtonHighlightView.isHidden = false
                flashButtonHighlightView.fadeIn(duration: 0.2, delay: 0)
            } else {
                flashButtonHighlightView.fadeOut(0.2) { [weak self] finish in
                    self?.flashButtonHighlightView.isHidden = true
                }
            }
            
        } catch {
            presentErrorAlert(with: error)
        }

    }
    
    @IBAction func addFromDeviceButtonPressed(_ sender: UIButton) {

        heroNavigationControllerDelegateCache = navigationController?.delegate
        imagePicker.delegate = self
        
        present(imagePicker, animated: true) { [weak self] in
            self?.animatePauseSession()
        }
        
    }
    
    //MARK: - Selectors
    
    @objc func visionViewDidSwipeDown(_ sender: UISwipeGestureRecognizer) {
        
        animateOut()
    }
    
    @objc func visionViewDidPinch(_ sender: UIPinchGestureRecognizer) {
        
        captureSessionQueue.async { [weak self] in
            
            guard let device = self?.captureDevice else { return }

            if sender.state == .changed {

                let maxZoomFactor =  min(device.activeFormat.videoMaxZoomFactor, 5)
                let pinchVelocityDividerFactor: CGFloat = 10.0

                do {

                    try device.lockForConfiguration()
                    defer { device.unlockForConfiguration() }

                    let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor)
                    device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))

                } catch {
                    print(error)
                }
            }

        }

    }
    
    //MARK: - Vision Methods
    
    private func setupCaptureSession() throws {
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            throw CDError.cameraFailed
        }

        self.captureDevice = captureDevice

        captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        bufferAspectRatio = 1920.0 / 1080.0
        
        var deviceInput: AVCaptureDeviceInput?
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch {
            throw CDError.cameraFailed
        }
        
        guard let deviceInput = deviceInput else { return }
        
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }
        
        // Configure video data output.
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        
        if captureSession.canAddOutput(videoDataOutput) {
            
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .auto
        } else {
            throw CDError.cameraFailed
        }
        
        // Set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 1.2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            throw CDError.cameraFailed
        }
        
        captureSession.startRunning()
    }
    
    func calculateRegionOfInterest() {
        
        // Figure out size of ROI.
        let size = CGSize(width: 0.9, height: 0.2)

        // Make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        
        
//        // Update the cutout to match the new ROI.
        DispatchQueue.main.async { [weak self] in
            self?.updateVisionFocusViewCutout()
            
            self?.visionViewActivityIndicatorCenterYAnchor.constant = ((self?.view.frame.height ?? 0) * 0.1) + (self?.visionViewActivityIndicator.frame.height ?? 0) * 0.75
            self?.updateViewConstraints()
        }
    }
    
    func updateVisionFocusViewCutout() {
            // Figure out where the cutout ends up in layer coordinates.
        
        var rect = CGRect()
        rect.size = CGSize(width: 0.2, height: 0.7)
        rect.origin = CGPoint(x: 0.4, y: 0.15)
        
        let cutout = visionView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: rect)
            
            // Create the mask.
            let path = UIBezierPath(roundedRect: visionFocusView.frame, cornerRadius: 13)
            path.append(UIBezierPath(roundedRect: cutout, cornerRadius: 13))
            visionFocusMaskLayer.path = path.cgPath
    }
    
    private func toggleFlash() throws -> Bool {
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw CDError.genericCamera
        }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if (device.torchMode == .on) {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: 1.0)
                }
                device.unlockForConfiguration()
                return device.torchMode == .on
            } catch {
                throw CDError.flashFailed
            }
        } else {
            throw CDError.flashUnavailable
        }
    }
    
    //Detection Methods
    
    private func checkForPotentialPlateNumbers(in strings: [String]) {
        for string in strings {
            let cleanString = string.including(only: "1234567890").trimming(character: "0", from: .beginning)
            
            if  cleanString.contains(only: "1234567890"),
                LicensePlateManager.licensePlateIsValid(cleanString) {
                
                if !didDetectInitialLicensePlate {
                    didDetectFirstSample()
                }
                
                potentialPlateNumbers.append(cleanString)
                
                timeSinceLastSampleDetection = 0
                
                attemptMostProbablePlateNumber()
                
            }
        }
    }
    
    private func attemptMostProbablePlateNumber() {
        guard potentialPlateNumbers.count >= licensePlateSampleThreshold else {
            return
        }
        
        let countedSet = NSCountedSet(array: potentialPlateNumbers)
        
        if let mostFrequent = countedSet.max(by: { countedSet.count(for: $0) < countedSet.count(for: $1) }) as? String,
            LicensePlateManager.licensePlateIsValid(mostFrequent) {
            
            didDetect(plate: mostFrequent)
                
        } else if let longest = potentialPlateNumbers.max(by: {$1.count > $0.count}),
            LicensePlateManager.licensePlateIsValid(longest) {
            
            didDetect(plate: longest)
        }

        potentialPlateNumbers.removeAll()
    }
    
    private func recognizeLicensePlateNumber(in image: CGImage?) throws {
        
        guard let image = image else {
            throw CDError.noImageForRecognition
        }
        
        //similar to regular recognition request but does not use sample cound guard, and runs only once so it can output failure
        let staticRecognitionrequest = VNRecognizeTextRequest(completionHandler: handleImage(request:error:))
        
        let handler = VNImageRequestHandler(cgImage: image)
        
        do {
            //calls handle(request:error:) defined in VNRecognitionHandler extension
            try handler.perform([staticRecognitionrequest])
        } catch {
            throw error
        }
    }
        
    
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VisionViewController: VNRecognitionHandler, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func handle(request: VNRequest, error: Error?) {
        
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        // Process the recognized strings.
        checkForPotentialPlateNumbers(in: recognizedStrings)
    }
    
    func handleImage(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        var recognizedStrings: [VNRecognizedText] = []
        
        for observation in observations {
            let observationCandidates = observation.topCandidates(3)
            
            for candidate in observationCandidates {
                recognizedStrings.append(candidate)
            }
        }
        
        var potentialStaticNumbers: [String] = []
        
        for candidate in recognizedStrings {
            let cleanString = candidate.string.including(only: "1234567890").trimming(character: "0", from: .beginning)
            
            if  cleanString.contains(only: "1234567890"),
                LicensePlateManager.licensePlateIsValid(cleanString) {
                
                potentialStaticNumbers.append(cleanString)
            }
        }
        
        guard potentialStaticNumbers.count > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.animateResumeSession {
                    self?.presentErrorAlert(with: CDError.noResultsForImageRecognition)
                }
            }
            return
        }
        
        let countedSet = NSCountedSet(array: potentialStaticNumbers)
        
        if let mostFrequent = countedSet.max(by: { countedSet.count(for: $0) < countedSet.count(for: $1) }) as? String,
            LicensePlateManager.licensePlateIsValid(mostFrequent) {
            
            didDetect(plate: mostFrequent)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.animateResumeSession {
                    self?.presentErrorAlert(with: CDError.noResultsForImageRecognition)
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let request = recognitionrequest {
            // Configure for running in real-time.
            request.recognitionLevel = .accurate
            // Language correction won't help recognizing phone numbers. It also
            // makes recognition slower.
            request.usesLanguageCorrection = false
            // Only run on the region of interest for maximum speed.
            request.regionOfInterest = regionOfInterest
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                presentErrorAlert(with: CDError.genericCamera)
            }
        }
    }
}

extension VisionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            
            didSelect(imageForPlateRecognition: image)
        }
        
        picker.dismiss(animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        captureSessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
            
            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self?.animateResumeSession()
                }
            }
        }

    }
    
}

extension VisionViewController: LoadResultDelegate {
    func resultLoader(didFailWith error: Error, for licensePlate: String?) {
        
        licensePlateLabel.isHidden = true
        licensePlateHeroView.isHidden = true
        
        captureSessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
        
        let cancelAction = UIAlertAction(title: "ביטול", style: .cancel) { [weak self] action in
            
            self?.licensePlateHeroView.heroID = ""
            self?.navigationController?.heroNavigationAnimationType = .slide(direction: .down)
            
            self?.navigationController?.popViewController(animated: true)
        }
        
        let retryAction = UIAlertAction(title: "ניסוי מחדש", style: .default) { [weak self] action in
            
            self?.staticRecognitionImageView.fadeOut() { finish in
                self?.staticRecognitionImageView.removeFromSuperview()
            }
            
            self?.animateResumeSession {
                self?.didDetectInitialLicensePlate = false
            }

        }
        
        let errorDescription: String?
        
        if let error = error as? CDError {
            errorDescription = error.localizedDescription
        } else {
            errorDescription = error.localizedDescription
        }
        
        presentErrorAlert(with: error, withDescription: true, customDesription: errorDescription, actions: [cancelAction, retryAction])
        
    }
    
}

