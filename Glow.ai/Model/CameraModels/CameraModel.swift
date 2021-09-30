//
//  CameraModel.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 30/09/2021.
//

import AVFoundation

struct CameraModel {
    // MARK: Capture session propreties
    let captureSession = AVCaptureSession()
    var activeInput: AVCaptureDeviceInput!
    let videoOutput = AVCaptureVideoDataOutput()
    let audioOutput = AVCaptureAudioDataOutput()
    let videoDataOutputQueue = DispatchQueue(
                                          label: "com.glow.videoOutput",
                                            qos: .userInteractive)
}
