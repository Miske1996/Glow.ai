//
//  VideoWriter.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//

import Foundation
import AVFoundation
import Photos


class VideoWriter {
    
    // MARK: AVAssetWriter propreties
    var sessionAtSourceTime:CMTime?
    var videoWriter:AVAssetWriter?
    let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
                        AVVideoCodecKey : AVVideoCodecType.h264,
                        AVVideoWidthKey : 720,
                        AVVideoHeightKey : 1280,
                        AVVideoCompressionPropertiesKey : [
                            AVVideoAverageBitRateKey : 2300000,
                            ],
                        ])
    let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
    var tempURL: URL?
    var isRecording:Bool = false
    
    
    func writerSetup(){
        do {
            self.tempURL = videoFileLocation()
            videoWriter = try AVAssetWriter(outputURL: self.tempURL!, fileType: AVFileType.mov)
            // add video input
            videoWriterInput.expectsMediaDataInRealTime = true
            if videoWriter!.canAdd(videoWriterInput) {
                videoWriter!.add(videoWriterInput)
                } else {
                }
                // add audio input
                audioWriterInput.expectsMediaDataInRealTime = true
            if videoWriter!.canAdd(audioWriterInput) {
                videoWriter!.add(audioWriterInput)
                }
            videoWriter!.startWriting()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    
    func start() {
        guard !isRecording else { return }
        isRecording = true
        sessionAtSourceTime = nil
        self.writerSetup()
        if videoWriter!.status == .writing {
        } else if videoWriter!.status == .failed {
        } else if videoWriter!.status == .cancelled {
        } else if videoWriter?.status == .unknown {
        } else {
        }

        
    }
    func stop(completion:@escaping (Bool)->()) {
        
        guard isRecording else { return }
        isRecording = false
        videoWriterInput.markAsFinished()
        audioWriterInput.markAsFinished()
        videoWriter!.finishWriting { [weak self] in
            self?.sessionAtSourceTime = nil
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: (self?.tempURL!)!)
            } completionHandler: { (success, error) in
                if success {
                    completion(success)
                }
            }
        }
    }
    func canWrite() -> Bool {
        return isRecording && videoWriter != nil && videoWriter?.status == .writing
    }

 
    
    func videoFileLocation() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let videoOutputUrl = URL(fileURLWithPath: documentsPath.appendingPathComponent("videoFile")).appendingPathExtension("mov")
        do {
            if FileManager.default.fileExists(atPath: videoOutputUrl.path) {
            try FileManager.default.removeItem(at: videoOutputUrl)
            }
        } catch {
            print(error)
        }
        return videoOutputUrl
    }

}
