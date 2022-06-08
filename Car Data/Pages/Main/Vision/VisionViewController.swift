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
}

extension VisionViewDelegate {
    func visionViewDidCancelSearch() { }
}


final class VisionViewController: CDViewController {

    @IBOutlet weak var visionView: LiveCameraView!
    
    @IBOutlet weak var instructionLabel: PaddingLabel!
    
    @IBOutlet weak var licensePlateLabel: PaddingLabel!
    
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
        
        Hero.shared.delegate = self
    }
    
    override func setupViews() {
        super.setupViews()
        
        setupInstructionLabel()
        setupVisionView()
    }
    
    private func setupVisionView() {
        visionView.session = captureSession
        
        captureSessionQueue.async { [weak self] in
            self?.setupCaptureSession()
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.visionView.fadeOut(0.2) { finish in
                    
                    self?.visionView.session?.stopRunning()
                }
            }
        }
        
    }
    
    
    //MARK: - IB Actions
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        animateOut()
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {
        //toggle flash
    }
    
    @IBAction func addFromDeviceButtonPressed(_ sender: UIButton) {
        
    }
    
    //MARK: - Vision Methods
    
    private func setupCaptureSession() {
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("Could not create capture device.")
            return
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
            print("Could not create device input. \(error)")
            return
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
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            print("Could not add VDO output")
            return
        }
        
        // Set zoom and autofocus to help focus on very small text.
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
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
    
}

//MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension VisionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This is implemented in VisionViewController.
    }
}

//MARK - HeroTransitionDelegate

extension VisionViewController: HeroTransitionDelegate, HeroViewControllerDelegate {
    func heroTransition(_ hero: HeroTransition, didUpdate state: HeroTransitionState) {}
    func heroTransition(_ hero: HeroTransition, didUpdate progress: Double) {}
    
    func heroDidEndAnimatingTo(viewController: UIViewController) {
        if viewController is MainViewController {
            delegate?.visionViewDidCancelSearch()
        }
    }
    
}

