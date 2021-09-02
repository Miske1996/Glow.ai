//
//  Camera.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//

import AVFoundation
import SwiftUI
import Photos
import Vision
class Camera: NSObject, ObservableObject {
    
    
    // MARK: UIImage processed and sent to display
    @Published var displayImage:UIImage = UIImage()
    
    // MARK: Detected Features propreties
    var posturekeypoints:[CGPoint]?
    
    
    // MARK: Capture session propreties
    let captureSession = AVCaptureSession()
    var activeInput: AVCaptureDeviceInput!
    let videoOutput = AVCaptureVideoDataOutput()
    let audioOutput = AVCaptureAudioDataOutput()
    private let videoDataOutputQueue = DispatchQueue(
                                          label: "com.glow.videoOutput",
                                            qos: .userInteractive)
    
    // MARK: AVAssetWriter Manager
    var writerManager = VideoWriter()


    // MARK: Capture session Functions
    
    public func setupCamera() {
        setupSession()
        startSession()
    }
    
    func setupSession() {
        captureSession.beginConfiguration()
        guard let camera = AVCaptureDevice.default(for: .video) else {
        return
        }
        guard let mic = AVCaptureDevice.default(for: .audio) else {
        return
        }
        do {
        let videoInput = try AVCaptureDeviceInput(device: camera)
        let audioInput = try AVCaptureDeviceInput(device: mic)
        for input in [videoInput, audioInput] {
          if captureSession.canAddInput(input) {
            captureSession.addInput(input)
          }
        }
        activeInput = videoInput
        } catch {
            print("Error setting device input: \(error)")
            return
        }

        if captureSession.canAddOutput(videoOutput){
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            captureSession.addOutput(videoOutput)
        }

        if captureSession.canAddOutput(audioOutput){
            audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            captureSession.addOutput(audioOutput)
        }

        captureSession.commitConfiguration()
    }
    
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .default).async { [weak self] in
            self?.captureSession.startRunning()
        }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .default).async() { [weak self] in
            self?.captureSession.stopRunning()
        }
        }
    }
    
    func camera(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        let devices = discovery.devices.filter {
        $0.position == position
        }
        return devices.first
    }

    public func switchCamera() {
        let position: AVCaptureDevice.Position = (activeInput.device.position == .back) ? .front : .back
        guard let device = camera(for: position) else {
          return
        }
        captureSession.beginConfiguration()
        captureSession.removeInput(activeInput)
        do {
        activeInput = try AVCaptureDeviceInput(device: device)
        } catch {
        print("error: \(error.localizedDescription)")
        return
        }
        captureSession.addInput(activeInput)
        captureSession.commitConfiguration()
    }

}



// MARK: Received frames and audio From Devices

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate {
  
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Recording Video
        
        let writable = writerManager.canWrite()
        if writable,
           writerManager.sessionAtSourceTime == nil {
            // start writing
            writerManager.sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            writerManager.videoWriter!.startSession(atSourceTime: writerManager.sessionAtSourceTime!)
        }

        if output == videoOutput {
            connection.videoOrientation = .portrait
        }
       
        if writable,output == videoOutput,(writerManager.videoWriterInput.isReadyForMoreMediaData) {
            // write video buffer
            writerManager.videoWriterInput.append(sampleBuffer)
        } else if writable,output == audioOutput,(writerManager.audioWriterInput.isReadyForMoreMediaData) {
            // write audio buffer
            writerManager.audioWriterInput.append(sampleBuffer)
        }
        
        // Processing images
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let uiImage = UIImage(cgImage: cgImage)
        
        
        
        // publishing changes to the main thread and Processing images
        DispatchQueue.main.async {
            
            self.displayImage = uiImage
            // Create a new image-request handler.

            let requestHandler = VNImageRequestHandler(cgImage: (uiImage.cgImage!))

            // Create a new request to recognize a human body pose.
            let request = VNDetectHumanBodyPoseRequest(completionHandler: self.bodyPoseHandler)

            do {
                // Perform the body pose-detection request.
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform the request: \(error).")
            }
        }
    }
}
    




// MARK: FEATURES DETECTION FUNCTIONS
extension Camera {
   
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
            request.results as? [VNHumanBodyPoseObservation] else {
        return
        }
        // Process each observation to find the recognized body pose points.
        observations.forEach { processObservation($0) }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation)  {
        // Retrieve all torso points.
        guard let recognizedPoints =
            try? observation.recognizedPoints(.all) else { return }

        // Torso joint names in a clockwise ordering.
        let kp: [VNHumanBodyPoseObservation.JointName] = [
            .leftAnkle,
            .leftKnee,
            .leftHip,
            .leftWrist,
            .leftElbow,
            .leftShoulder,
            .rightShoulder,
            .rightElbow,
            .rightWrist,
            .rightHip,
            .rightKnee,
            .rightAnkle,
        ]
        let imagePoints: [CGPoint] = kp.compactMap {
        guard let point = recognizedPoints[$0], point.confidence > 0.55 else { return nil }
        var pt = CGPoint(x: point.x * 550 , y: point.y * 1000)
        pt.y = 910 - pt.y
        pt.x = pt.x - 15
        return pt
        }
        self.posturekeypoints = imagePoints
    }
  
}
