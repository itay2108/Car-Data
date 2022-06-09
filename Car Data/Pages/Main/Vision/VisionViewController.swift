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
    
    var delegate: VisionViewDelegate?
    
    //Live Preview Parameters
    
    private let captureSession = AVCaptureSession()
    let captureSessionQueue = DispatchQueue(label: K.queueIDs.captureSession)
    
    var captureDevice: AVCaptureDevice?
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: K.queueIDs.videoOutputSession)
    
    //Vision Parameters
    var bufferAspectRatio: Double!
    
    var regionOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)
    let visionFocusMaskLayer = CAShapeLayer()
    
    var visionBlurView: UIVisualEffectView?
    
    private var request: VNRecognizeTextRequest?
    
    //vision detections that match plate rules get added to this array. when array contains enough samples, use the most frequent sample. if no frequent, use the longest sample.
    private var didDetectInitialLicensePlate: Bool = false
    
    private var timeSinceLastSampleDetection: Int = 0
    private var sampleFrequencyTimer: Timer?
    
    private var potentialPlateNumbers: [String] = []
    private var licensePlateSampleThreshold: Int = 15
    
    //MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        animateIn()
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
    
    override func setupUI() {
        super.setupUI()
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupInstructionLabel()
        setupVisionView()
        setupLicensePlateLabel()
    }
    
    private func setupVisionView() {
        request = VNRecognizeTextRequest(completionHandler: handle(request:error:))
        
        visionView.session = captureSession
        
        captureSessionQueue.async { [weak self] in
            
            do {
                try self?.setupCaptureSession()
                
                self?.animateInstructionIn()
            }
            catch {
                self?.presentErrorAlert(with: error)
            }

            // Calculate region of interest now that the camera is setup.
            DispatchQueue.main.async {
                // Figure out initial ROI.
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
        
        visionFocusView.isUserInteractionEnabled = true
        visionFocusView.addGestureRecognizer(swipeGR)
        
        updateVisionFocusViewCutout()
    }
    
    private func setupLicensePlateLabel() {
        licensePlateLabel.layer.cornerRadius = 13
        licensePlateLabel.layer.masksToBounds = true
    }
    
    private func animateIn() {
        
        visionView.fadeIn()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.visionView.backgroundColor = K.colors.backgroundDark
            
        }
    }
    
    private func animateOut() {
        instructionLabel.isHidden = true
        
        navigationController?.heroNavigationAnimationType = .slide(direction: .down)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.visionView.fadeOut(0.1)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    private func animateSuccess(_ completion: (()->Void)? = nil) {
        visionViewActivityIndicator.stopAnimating()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        visionBlurView = UIVisualEffectView(effect: blurEffect)
        
        guard let visionBlurView = visionBlurView else {
            return
        }
        
        visionBlurView.frame = view.bounds
        visionBlurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(visionBlurView, belowSubview: licensePlateLabel)
        
        visionBlurView.fadeIn() { [weak self] in
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            self?.visionFocusView.isHidden = true
            
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
        
    }
    
    //MARK: - Selectors
    
    @objc func visionViewDidSwipeDown(_ sender: UISwipeGestureRecognizer) {
        
        animateOut()
    }
    
    //MARK: - Vision Methods
    
    private func setupCaptureSession() throws {
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            throw CDError.cameraFailed
        }

        self.captureDevice = captureDevice

        if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }
        
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
        for string in recognizedStrings {
            let cleanString = string.excluding(characrers: "-.,;:•")
            
            if  cleanString.contains(only: "1234567890"),
                LicensePlateManager.licensePlateIsValid(cleanString) {
                
                
                if !didDetectInitialLicensePlate {
                    didDetectFirstSample()
                }
                
                potentialPlateNumbers.append(cleanString)
                
                timeSinceLastSampleDetection = 0
                

                
                if potentialPlateNumbers.count >= licensePlateSampleThreshold {
                    attemptMostProbablePlateNumber()
                }
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let request = request {
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
            
            self?.visionFocusView.isHidden = false
            self?.visionFocusView.fadeIn()
            self?.visionBlurView?.fadeOut()
            
            self?.didDetectInitialLicensePlate = false
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

