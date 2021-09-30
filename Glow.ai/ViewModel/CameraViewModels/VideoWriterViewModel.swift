//
//  VideoWriter.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//

import Foundation
import AVFoundation
import Photos
import UIKit

class VideoWriterViewModel {
    

    var videoWriterObject = VideoWriterModel()
    
    
    func writerSetup(){
        do {
            self.videoWriterObject.videoWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: self.videoWriterObject.videoWriterInput,
                sourcePixelBufferAttributes: videoWriterObject.sourcePixelBufferAttributes)
            self.videoWriterObject.tempURL = videoFileLocation()
            videoWriterObject.avAssetWriter = try AVAssetWriter(outputURL: self.videoWriterObject.tempURL!, fileType: AVFileType.mov)
            // add video input
            videoWriterObject.videoWriterInput.expectsMediaDataInRealTime = true
            if videoWriterObject.avAssetWriter!.canAdd(videoWriterObject.videoWriterInput) {
                videoWriterObject.avAssetWriter!.add(videoWriterObject.videoWriterInput)
                } else {
                }
                // add audio input
            videoWriterObject.audioWriterInput.expectsMediaDataInRealTime = true
            if videoWriterObject.avAssetWriter!.canAdd(videoWriterObject.audioWriterInput) {
                videoWriterObject.avAssetWriter!.add(videoWriterObject.audioWriterInput)
                }
            videoWriterObject.avAssetWriter!.startWriting()
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    
    func start() {
        guard !videoWriterObject.isRecording else { return }
        videoWriterObject.isRecording = true
        videoWriterObject.sessionAtSourceTime = nil
        self.writerSetup()
        if videoWriterObject.avAssetWriter!.status == .writing {
        } else if videoWriterObject.avAssetWriter!.status == .failed {
        } else if videoWriterObject.avAssetWriter!.status == .cancelled {
        } else if videoWriterObject.avAssetWriter?.status == .unknown {
        } else {
        }

        
    }
    func stop(completion:@escaping (Bool)->()) {
        
        guard videoWriterObject.isRecording else { return }
        videoWriterObject.isRecording = false
        videoWriterObject.videoWriterInput.markAsFinished()
        videoWriterObject.audioWriterInput.markAsFinished()
        videoWriterObject.avAssetWriter!.finishWriting { [weak self] in
            self?.videoWriterObject.sessionAtSourceTime = nil
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: (self?.videoWriterObject.tempURL!)!)
            } completionHandler: { (success, error) in
                if success {
                    completion(success)
                }
            }
        }
    }
    func canWrite() -> Bool {
        return videoWriterObject.isRecording && videoWriterObject.avAssetWriter != nil && videoWriterObject.avAssetWriter?.status == .writing
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
