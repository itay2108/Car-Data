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
    
    @IBOutlet weak var instructionLabel: PaddingLabel!
    
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
    
    private var request: VNRecognizeTextRequest?
    
    private let stringTracker = StringTracker()
    
    //MARK: - Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateIn()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Hero.shared.delegate = nil
    }
    
    //MARK: - UI Methods
    
    override func setupUI() {
        super.setupUI()
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupInstructionLabel()
        setupVisionView()
    }
    
    private func setupVisionView() {
        request = VNRecognizeTextRequest(completionHandler: handle(request:error:))
        
        visionView.session = captureSession
        
        captureSessionQueue.async { [weak self] in
            
            do {
                try self?.setupCaptureSession()
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
        visionView.addGestureRecognizer(swipeGR)
        
        updateVisionFocusViewCutout()
    }
    
    private func animateIn() {
        
        visionView.fadeIn()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.visionView.backgroundColor = K.colors.backgroundDark
            
        } completion: { [weak self] didComplete in
            guard didComplete else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.instructionLabel.isHidden = false
                self?.instructionLabel.fadeIn()
                
            }
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
    
    
    //MARK: - IB Actions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        captureSessionQueue.async { [weak self] in
            self?.visionView.session?.stopRunning()
        }
        
        animateOut()
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {

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

        let desiredHeightRatio = 1.16
        let desiredWidthRatio = 0.16
        let maxPortraitWidth = 0.5
        
        // Figure out size of ROI.
        let size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)

        // Make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        
        
//        // Update the cutout to match the new ROI.
        DispatchQueue.main.async { [weak self] in
            self?.updateVisionFocusViewCutout()
        }
    }
    
    func updateVisionFocusViewCutout() {
            // Figure out where the cutout ends up in layer coordinates.
        
        let cutout = visionView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: regionOfInterest)
            
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
        print(recognizedStrings)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
           let request = request {
            // Configure for running in real-time.
            request.recognitionLevel = .fast
            // Language correction won't help recognizing phone numbers. It also
            // makes recognition slower.
            request.usesLanguageCorrection = false
            // Only run on the region of interest for maximum speed.
            request.regionOfInterest = regionOfInterest
            
            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

