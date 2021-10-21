//
//  Camera.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//

import SwiftUI
import Photos
import Vision
import Combine
class CameraViewModel: NSObject, ObservableObject {
    
    
    // MARK: UIImage processed and sent to display
    @Published var displayImage:UIImage = UIImage()
    @Published var alpha:CGFloat = 0
    // MARK: Detected Features propreties
    var posturekeypoints:[CGPoint]?
    var faceBox:CGRect?
    var imageSize:CGSize?
    var nosePoint:CGPoint?
    var rootPoint:CGPoint?
    var neckPoint:CGPoint?
    var leftLegPoints:[CGPoint]?
    var leftArmPoints:[CGPoint]?
    var rightLegPoints:[CGPoint]?
    var rightArmPoints:[CGPoint]?
    var torsoPoints:[CGPoint]?
    // MARK: Camera Model
    var cameraModel = CameraModel()
    
    // MARK: VideoWriterViewModel
    var videoWriterViewModel = VideoWriterViewModel()


    // MARK: Capture session Functions
    
    public func setupCamera() {
    
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
            bonesShape.lineCap = .round
            bonesShape.lineJoin = .round
            bonesShape.fillColor = .none
            bonesShape.strokeColor = UIColor.red.cgColor
            bonesShape.lineWidth = 13
            bonesShape.path = bonespath.cgPath
            bonesShape.shadowRadius = 20
            bonesShape.shadowOpacity = 1.0
            bonesShape.shadowOffset = .zero
            bonesShape.shadowColor = UIColor.red.cgColor
          
            let faceShape = CAShapeLayer()
            if self.nosePoint != nil {
                let facePath = UIBezierPath()
                facePath.addArc(withCenter: CGPoint(x: self.nosePoint!.x, y: self.nosePoint!.y - 80) , radius: 95, startAngle: .zero, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                facePath.move(to: CGPoint(x: self.nosePoint!.x - 50, y: self.nosePoint!.y - 120))
                facePath.addLine(to:CGPoint(x: self.nosePoint!.x - 20, y: self.nosePoint!.y - 95))
                
                facePath.move(to: CGPoint(x: self.nosePoint!.x - 20, y: self.nosePoint!.y - 120))
                facePath.addLine(to:CGPoint(x: self.nosePoint!.x - 50, y: self.nosePoint!.y - 95))
                
                
                facePath.move(to: CGPoint(x: self.nosePoint!.x + 50, y: self.nosePoint!.y - 120))
                facePath.addLine(to:CGPoint(x: self.nosePoint!.x + 20, y: self.nosePoint!.y - 95))
                
                facePath.move(to: CGPoint(x: self.nosePoint!.x + 20, y: self.nosePoint!.y - 120))
                facePath.addLine(to:CGPoint(x: self.nosePoint!.x + 50, y: self.nosePoint!.y - 95))
                
                facePath.move(to: CGPoint(x: self.nosePoint!.x - 45, y: self.nosePoint!.y - 30))
                facePath.addQuadCurve(to: CGPoint(x: self.nosePoint!.x + 45, y: self.nosePoint!.y - 30), controlPoint: CGPoint(x: self.nosePoint!.x, y: self.nosePoint!.y + 10 ))
                
                
                
                
                faceShape.lineCap = .round
                faceShape.lineJoin = .round
                faceShape.fillColor = .none
                faceShape.strokeColor = UIColor.red.cgColor
                faceShape.lineWidth = 10
                faceShape.path = facePath.cgPath
                faceShape.shadowRadius = 20
                faceShape.shadowOpacity = 1.0
                faceShape.shadowOffset = .zero
                faceShape.shadowColor = UIColor.red.cgColor
            }
            
            let leftLegShape = CAShapeLayer()
            if (self.leftLegPoints != nil) &&  !self.leftLegPoints!.isEmpty  {
                let leftLegPath = UIBezierPath()
                leftLegPath.move(to: leftLegPoints![0])
                leftLegPath.addLine(to: leftLegPoints![1])
                leftLegPath.addLine(to: leftLegPoints![2])
                
                
                leftLegShape.lineCap = .round
                leftLegShape.lineJoin = .round
                leftLegShape.fillColor = .none
                leftLegShape.strokeColor = UIColor.red.cgColor
                leftLegShape.lineWidth = 10
                leftLegShape.path = leftLegPath.cgPath
                leftLegShape.shadowRadius = 20
                leftLegShape.shadowOpacity = 1.0
                leftLegShape.shadowOffset = .zero
                leftLegShape.shadowColor = UIColor.red.cgColor
            }
            let rightLegShape = CAShapeLayer()
            if (self.rightLegPoints != nil) &&  !self.rightLegPoints!.isEmpty  {
                let rightLegPath = UIBezierPath()
                rightLegPath.move(to: rightLegPoints![0])
                rightLegPath.addLine(to: rightLegPoints![1])
                rightLegPath.addLine(to: rightLegPoints![2])
                
               
                rightLegShape.lineCap = .round
                rightLegShape.lineJoin = .round
                rightLegShape.fillColor = .none
                rightLegShape.strokeColor = UIColor.red.cgColor
                rightLegShape.lineWidth = 10
                rightLegShape.path = rightLegPath.cgPath
                rightLegShape.shadowRadius = 20
                rightLegShape.shadowOpacity = 1.0
                rightLegShape.shadowOffset = .zero
                rightLegShape.shadowColor = UIColor.red.cgColor
            }
            let leftArmShape = CAShapeLayer()
            if (self.leftArmPoints != nil) &&  !self.leftArmPoints!.isEmpty  {
                let leftArmPath = UIBezierPath()
//                leftArmPath.addArc(withCenter: CGPoint(x: leftArmPoints![2].x
//                                                        + 20, y: leftArmPoints![2].y + 30), radius: 30, startAngle: .zero, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                leftArmPath.move(to: leftArmPoints![0])
                leftArmPath.addLine(to: leftArmPoints![1])
                leftArmPath.addLine(to: leftArmPoints![2])
                
                
                leftArmShape.lineCap = .round
                leftArmShape.lineJoin = .round
                leftArmShape.fillColor = .none
                leftArmShape.strokeColor = UIColor.red.cgColor
                leftArmShape.lineWidth = 10
                leftArmShape.path = leftArmPath.cgPath
                leftArmShape.shadowRadius = 20
                leftArmShape.shadowOpacity = 1.0
                leftArmShape.shadowOffset = .zero
                leftArmShape.shadowColor = UIColor.red.cgColor
            }
            let rightArmShape = CAShapeLayer()
            if (self.rightArmPoints != nil) &&  !self.rightArmPoints!.isEmpty  {
                let rightArmPath = UIBezierPath()
//                rightArmPath.addArc(withCenter: CGPoint(x: rightArmPoints![2].x - 20, y: rightArmPoints![2].y + 30), radius: 30, startAngle: .zero, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                rightArmPath.move(to: rightArmPoints![0])
                rightArmPath.addLine(to: rightArmPoints![1])
                rightArmPath.addLine(to: rightArmPoints![2])
                
                
                
                rightArmShape.lineCap = .round
                rightArmShape.lineJoin = .round
                rightArmShape.fillColor = .none
                rightArmShape.strokeColor = UIColor.red.cgColor
                rightArmShape.lineWidth = 10
                rightArmShape.path = rightArmPath.cgPath
                rightArmShape.shadowRadius = 20
                rightArmShape.shadowOpacity = 1.0
                rightArmShape.shadowOffset = .zero
                rightArmShape.shadowColor = UIColor.red.cgColor
            }
            
            let torsoShape = CAShapeLayer()
            if (self.torsoPoints != nil) &&  !self.torsoPoints!.isEmpty && (self.rootPoint != nil)  &&  (self.neckPoint != nil)    {
                let torsoPath = UIBezierPath()
//                torsoPath.move(to: torsoPoints![0])
//                torsoPath.addLine(to: torsoPoints![1])
//                torsoPath.addLine(to: torsoPoints![2])
//                torsoPath.addLine(to: torsoPoints![3])
                torsoPath.move(to: neckPoint!)
                torsoPath.addLine(to: rootPoint!)
                torsoPath.move(to: neckPoint!)
                torsoPath.addLine(to: torsoPoints![0])
                torsoPath.move(to: neckPoint!)
                torsoPath.addLine(to: torsoPoints![1])
//                torsoPath.close()
                
                torsoShape.lineCap = .round
                torsoShape.lineJoin = .round
                torsoShape.fillColor = .none
                torsoShape.strokeColor = UIColor.red.cgColor
                torsoShape.lineWidth = 10
                torsoShape.path = torsoPath.cgPath
                torsoShape.shadowRadius = 20
                torsoShape.shadowOpacity = 1.0
                torsoShape.shadowOffset = .zero
                torsoShape.shadowColor = UIColor.red.cgColor
            }
            
            uiImage = UIGraphicsImageRenderer(bounds: rect, format: format).image { (ctx) in
                            if self.alpha != 0 {
                                uiImage.draw(at: CGPoint.zero, blendMode: .multiply, alpha: self.alpha)
                            }
//
//                            for point in self.posturekeypoints! {
//
//                                    ctx.cgContext.setFillColor(UIColor.gray.cgColor)
//                                    let rectangle = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)
//                                    ctx.cgContext.addEllipse(in: rectangle)
//                                    ctx.cgContext.drawPath(using: .fillStroke)
//
//                            }
                            if self.nosePoint != nil {
                                faceShape.render(in: ctx.cgContext)
                            }
                            
                            if (self.leftLegPoints != nil) &&  !self.leftLegPoints!.isEmpty  {
                                var isInadequate:Bool = false
                                for point in self.leftLegPoints! {
                                    if point.x < 1 || point.y < 1 {
                                       print("FOUND INDAQUATE POINT")
                                        isInadequate = true
                                    }
                                }
                                if !isInadequate {
                                    leftLegShape.render(in: ctx.cgContext)
                                }
                                
                            }
                            if (self.rightLegPoints != nil) &&  !self.rightLegPoints!.isEmpty  {
                                var isInadequate:Bool = false
                                for point in self.rightLegPoints! {
                                    if point.x < 1 || point.y < 1 {
                                       print("FOUND INDAQUATE POINT")
                                        isInadequate = true
                                    }
                                }
                                if !isInadequate {
                                    rightLegShape.render(in: ctx.cgContext)
                                }
                                
                            }
                            if (self.leftArmPoints != nil) &&  !self.leftArmPoints!.isEmpty  {
                                var isInadequate:Bool = false
                                for point in self.leftArmPoints! {
                                    if point.x < 1 || point.y < 1 {
                                       print("FOUND INDAQUATE POINT")
                                        isInadequate = true
                                    }
                                }
                                if !isInadequate {
                                    leftArmShape.render(in: ctx.cgContext)
                                }
                                
                            }
                            if (self.rightArmPoints != nil) &&  !self.rightArmPoints!.isEmpty  {
                                var isInadequate:Bool = false
                                for point in self.rightArmPoints! {
                                    if point.x < 1 || point.y < 1 {
                                       print("FOUND INDAQUATE POINT")
                                        isInadequate = true
                                    }
                                }
                                if !isInadequate {
                                    rightArmShape.render(in: ctx.cgContext)
                                }
                                
                            }
                            
                            if (self.torsoPoints != nil) &&  !self.torsoPoints!.isEmpty  {
                                var isInadequate:Bool = false
                                for point in self.torsoPoints! {
                                    if point.x < 1 || point.y < 1 {
                                       print("FOUND INDAQUATE POINT")
                                        isInadequate = true
                                    }
                                }
                                if !isInadequate {
                                    torsoShape.render(in: ctx.cgContext)
                                }
                                
                            }
//                            
                           
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
            .leftHip,
            .leftKnee,
            .leftAnkle,
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
            .root,
        ]
        if recognizedPoints[.root] != nil {
            self.rootPoint = CGPoint(x: recognizedPoints[.root]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.root]!.y) * Double(self.imageSize!.height))
        }
        if recognizedPoints[.nose] != nil {
            self.nosePoint = CGPoint(x: recognizedPoints[.nose]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.nose]!.y) * Double(self.imageSize!.height))
        }
        if recognizedPoints[.neck] != nil {
            self.neckPoint = CGPoint(x: recognizedPoints[.neck]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.neck]!.y) * Double(self.imageSize!.height))
        }
        if (recognizedPoints[.leftKnee] != nil) && (recognizedPoints[.leftAnkle] != nil) && (recognizedPoints[.leftHip] != nil) {
            let pt1 = CGPoint(x: recognizedPoints[.leftHip]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftHip]!.y) * Double(self.imageSize!.height))
            let pt2 = CGPoint(x: recognizedPoints[.leftKnee]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftKnee]!.y) * Double(self.imageSize!.height))
            let pt3 = CGPoint(x: recognizedPoints[.leftAnkle]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftAnkle]!.y) * Double(self.imageSize!.height))
            
            self.leftLegPoints = [pt1,pt2,pt3]
        }
        if (recognizedPoints[.leftShoulder] != nil) && (recognizedPoints[.leftElbow] != nil) && (recognizedPoints[.leftWrist] != nil) {
            let pt1 = CGPoint(x: recognizedPoints[.leftShoulder]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftShoulder]!.y) * Double(self.imageSize!.height))
            let pt2 = CGPoint(x: recognizedPoints[.leftElbow]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftElbow]!.y) * Double(self.imageSize!.height))
            let pt3 = CGPoint(x: recognizedPoints[.leftWrist]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftWrist]!.y) * Double(self.imageSize!.height))
            
            self.leftArmPoints = [pt1,pt2,pt3]
        }
        if (recognizedPoints[.rightAnkle] != nil) && (recognizedPoints[.rightHip] != nil) && (recognizedPoints[.rightKnee] != nil) {
            let pt1 = CGPoint(x: recognizedPoints[.rightHip]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightHip]!.y) * Double(self.imageSize!.height))
            let pt2 = CGPoint(x: recognizedPoints[.rightKnee]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightKnee]!.y) * Double(self.imageSize!.height))
            let pt3 = CGPoint(x: recognizedPoints[.rightAnkle]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightAnkle]!.y) * Double(self.imageSize!.height))
            
            self.rightLegPoints = [pt1,pt2,pt3]
        }
        if (recognizedPoints[.rightShoulder] != nil) && (recognizedPoints[.rightElbow] != nil) && (recognizedPoints[.rightWrist] != nil) {
            let pt1 = CGPoint(x: recognizedPoints[.rightShoulder]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightShoulder]!.y) * Double(self.imageSize!.height))
            let pt2 = CGPoint(x: recognizedPoints[.rightElbow]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightElbow]!.y) * Double(self.imageSize!.height))
            let pt3 = CGPoint(x: recognizedPoints[.rightWrist]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightWrist]!.y) * Double(self.imageSize!.height))
            
            self.rightArmPoints = [pt1,pt2,pt3]
        }
        if (recognizedPoints[.rightShoulder] != nil) && (recognizedPoints[.rightHip] != nil) && (recognizedPoints[.leftHip] != nil) && (recognizedPoints[.leftShoulder] != nil) {
            let pt1 = CGPoint(x: recognizedPoints[.rightShoulder]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightShoulder]!.y) * Double(self.imageSize!.height))
//            let pt2 = CGPoint(x: recognizedPoints[.rightHip]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.rightHip]!.y) * Double(self.imageSize!.height))
            let pt3 = CGPoint(x: recognizedPoints[.leftHip]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftHip]!.y) * Double(self.imageSize!.height))
            let pt4 = CGPoint(x: recognizedPoints[.leftShoulder]!.x * Double(self.imageSize!.width), y: (1 - recognizedPoints[.leftShoulder]!.y) * Double(self.imageSize!.height))
            self.torsoPoints = [pt4,pt1,pt3,pt4]
        }
        let imagePoints: [CGPoint] = joints.compactMap {
        guard let point = recognizedPoints[$0], point.confidence > 0.55 else { return nil }
        return CGPoint(x: point.x * Double(self.imageSize!.width) , y: (1 - point.y) * Double(self.imageSize!.height))
        }
        self.posturekeypoints = imagePoints
    }
  
}
