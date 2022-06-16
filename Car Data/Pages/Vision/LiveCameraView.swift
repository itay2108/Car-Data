//
//  LiveCameraView.swift
//  Car Data
//
//  Created by itay gervash on 08/06/2022.
//

import UIKit
import AVFoundation

class LiveCameraView: UIView {
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Could not initiate live viedo layer")
        }
        
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }
    
    var session: AVCaptureSession? {
        
        get {
            return videoPreviewLayer.session
        }
        
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
