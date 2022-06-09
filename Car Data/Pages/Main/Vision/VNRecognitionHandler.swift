//
//  VNRecognitionHandler.swift
//  Car Data
//
//  Created by itay gervash on 09/06/2022.
//

import Foundation
import Vision

protocol VNRecognitionHandler {
    func handle(request: VNRequest, error: Error?)
}
