//
//  Camera.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//

import SwiftUI
import Photos
import Vision
class CameraViewModel: NSObject, ObservableObject {
    
    
    // MARK: UIImage processed and sent to display
    @Published var displayImage:UIImage = UIImage()
    
    
    // MARK: Detected Features propreties
    var posturekeypoints:[CGPoint]?
    var faceBox:CGRect?
    var imageSize:CGSize?
//    var graphicsRenderer:UIGraphicsImageRenderer = UIGraphicsImageRenderer()

    
    // MARK: Camera Model
    var cameraModel = CameraModel()
    
    // MARK: VideoWriterViewModel
    var videoWriterViewModel = VideoWriterViewModel()


    // MARK: Capture session Functions
    
    public func setupCamera() {
//        let format = UIGraphicsImageRendererFormat()
//        format.scale = 0.8
//        format.opaque = true
//        format.preferredRange = .standard
//        self.graphicsRenderer = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: CGSize(width: 1080.0, height: 1920.0)), format: format)
        setupSession()
        startSession()
    }
    
    func setupSession() {
        cameraModel.captureSession.beginConfiguration()
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
            if cameraModel.captureSession.canAddInput(input) {
                cameraModel.captureSession.addInput(input)
          }
        }
            cameraModel.activeInput = videoInput
        } catch {
            print("Error setting device input: \(error)")
            return
        }

        if cameraModel.captureSession.canAddOutput(cameraModel.videoOutput){
            self.cameraModel.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.cameraModel.videoOutput.setSampleBufferDelegate(self, queue: cameraModel.videoDataOutputQueue)
            cameraModel.captureSession.addOutput(cameraModel.videoOutput)
        }

        if cameraModel.captureSession.canAddOutput(cameraModel.audioOutput){
            cameraModel.audioOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            cameraModel.captureSession.addOutput(cameraModel.audioOutput)
        }

        cameraModel.captureSession.commitConfiguration()
    }
    
    func startSession() {
        if !cameraModel.captureSession.isRunning {
            DispatchQueue.global(qos: .default).async { [weak self] in
                self?.cameraModel.captureSession.startRunning()
        }
        }
    }

    func stopSession() {
        if cameraModel.captureSession.isRunning {
            DispatchQueue.global(qos: .default).async() { [weak self] in
                self?.cameraModel.captureSession.stopRunning()
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
        let position: AVCaptureDevice.Position = (cameraModel.activeInput.device.position == .back) ? .front : .back
        guard let device = camera(for: position) else {
          return
        }
        cameraModel.captureSession.beginConfiguration()
        cameraModel.captureSession.removeInput(cameraModel.activeInput)
        do {
            cameraModel.activeInput = try AVCaptureDeviceInput(device: device)
        } catch {
        print("error: \(error.localizedDescription)")
        return
        }
        cameraModel.captureSession.addInput(cameraModel.activeInput)
        cameraModel.captureSession.commitConfiguration()
    }

}



// MARK: Received frames and audio From Devices

extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate {
  
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Recording Video
        
        let writable = videoWriterViewModel.canWrite()
        if writable,
           videoWriterViewModel.videoWriterObject.sessionAtSourceTime == nil {
            // start writing
            videoWriterViewModel.videoWriterObject.sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            videoWriterViewModel.videoWriterObject.avAssetWriter!.startSession(atSourceTime: videoWriterViewModel.videoWriterObject.sessionAtSourceTime!)
        }

        if output == cameraModel.videoOutput {
            connection.videoOrientation = .portrait
        }
       
        if writable,output == cameraModel.audioOutput,(videoWriterViewModel.videoWriterObject.audioWriterInput.isReadyForMoreMediaData) {
            // write audio buffer
            videoWriterViewModel.videoWriterObject.audioWriterInput.append(sampleBuffer)
        }
        
        // Processing images
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        var uiImage = UIImage(cgImage: cgImage)
        let rect = CGRect(origin: .zero, size: CGSize(width: uiImage.size.width, height: uiImage.size.height))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 0.5
        format.preferredRange = .standard
        
        //Get image size
        self.imageSize = uiImage.size
        
        if (self.posturekeypoints != nil) && !self.posturekeypoints!.isEmpty {
            let bonespath = UIBezierPath()
            bonespath.move(to: posturekeypoints![0])
            for i in 1...self.posturekeypoints!.count {
                if (i < self.posturekeypoints!.count ){
                    bonespath.addLine(to: self.posturekeypoints![i])
                }
            }
            bonespath.close()
            let bonesShape = CAShapeLayer()
            bonesShape.fillColor = .none
            bonesShape.strokeColor = UIColor.red.cgColor
            bonesShape.lineWidth = 13
            bonesShape.path = bonespath.cgPath
            bonesShape.shadowRadius = 20
            bonesShape.shadowOpacity = 1.0
            bonesShape.shadowOffset = .zero
            bonesShape.shadowColor = UIColor.red.cgColor
            uiImage = UIGraphicsImageRenderer(bounds: rect, format: format).image { (ctx) in
//                uiImage.draw(at: CGPoint.zero, blendMode: .multiply, alpha: 0.7)
                            bonesShape.render(in: ctx.cgContext)
                            for point in self.posturekeypoints! {
                       
                                    ctx.cgContext.setFillColor(UIColor.gray.cgColor)
                                    let rectangle = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
                                    ctx.cgContext.addEllipse(in: rectangle)
                                    ctx.cgContext.drawPath(using: .fillStroke)
                       
                            }
                           
                        }
        }
        

        
        if writable,output == cameraModel.videoOutput,((videoWriterViewModel.videoWriterObject.videoWriterInputPixelBufferAdaptor?.assetWriterInput.isReadyForMoreMediaData) != nil) {
            // write video buffer
            let buffer = imageToBuffer(from: uiImage)
            let currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            videoWriterViewModel.videoWriterObject.videoWriterInputPixelBufferAdaptor?.append(buffer!, withPresentationTime: currentSampleTime)
        }
        
        
        // publishing changes to the main thread and Processing images
        DispatchQueue.main.async {
            
            self.displayImage = uiImage
            // Create a new image-request handler.
            
        }
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer,
                                                   orientation: .up,
                                                   options: [:])

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: self.bodyPoseHandler)
        
  
        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }
    func imageToBuffer(from image: UIImage) -> CVPixelBuffer? {
      let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
      var pixelBuffer : CVPixelBuffer?
      let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
      guard (status == kCVReturnSuccess) else {
        return nil
      }

      CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
      let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

      let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
      let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

      context?.translateBy(x: 0, y: image.size.height)
      context?.scaleBy(x: 1.0, y: -1.0)

      UIGraphicsPushContext(context!)
      image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
      UIGraphicsPopContext()
      CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

      return pixelBuffer
    }
}
    




// MARK: FEATURES DETECTION FUNCTIONS
extension CameraViewModel {
   
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
        let joints: [VNHumanBodyPoseObservation.JointName] = [
            .leftEar,
            .leftEye,
            .nose,
            .rightEye,
            .rightEar,
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
            .neck,
            .root
        ]
        let imagePoints: [CGPoint] = joints.compactMap {
        guard let point = recognizedPoints[$0], point.confidence > 0.55 else { return nil }
        return CGPoint(x: point.x * Double(self.imageSize!.width) , y: (1 - point.y) * Double(self.imageSize!.height))
        }
        self.posturekeypoints = imagePoints
    }
  
}
