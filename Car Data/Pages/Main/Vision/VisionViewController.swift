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
    
    private var request: VNRecognizeTextRequest?
    
    private let numberTracker = StringTracker()
    
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
        visionView.session = captureSession
        
        let swipeGR = UISwipeGestureRecognizer(target: self, action: #selector(visionViewDidSwipeDown(_:)))
        swipeGR.direction = .down
        visionView.addGestureRecognizer(swipeGR)
        
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
    }
    
    private func setupInstructionLabel() {
        instructionLabel.layer.cornerRadius = 6
        instructionLabel.layer.masksToBounds = true
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
        }.then
        
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
            captureDevice.videoZoomFactor = 1.5
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            throw CDError.cameraFailed
        }
        
        captureSession.startRunning()
    }
    
    func calculateRegionOfInterest() {
        // In landscape orientation the desired ROI is specified as the ratio of
        // buffer width to height. When the UI is rotated to portrait, keep the
        // vertical size the same (in buffer pixels). Also try to keep the
        // horizontal size the same up to a maximum ratio.
        let desiredHeightRatio = 0.33
        let desiredWidthRatio = 0.6
        let maxPortraitWidth = 0.8
        
        // Figure out size of ROI.
        let size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)

        // Make it centered.
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size
        
//        // Update the cutout to match the new ROI.
//        DispatchQueue.main.async {
//            // Wait for the next run cycle before updating the cutout. This
//            // ensures that the preview layer already has its new orientation.
//            self.updateCutout()
//        }
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

extension VisionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This is implemented in VisionViewController.
    }
}

