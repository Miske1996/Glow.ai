//
//  VideoWriterModel.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 30/09/2021.
//
import AVFoundation
import UIKit

struct VideoWriterModel {
    // MARK: AVAssetWriter propreties
    var sessionAtSourceTime:CMTime?
    var avAssetWriter:AVAssetWriter?
    let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: [
                        AVVideoCodecKey : AVVideoCodecType.h264,
                        AVVideoWidthKey : 720,
                        AVVideoHeightKey : 1280,
                        AVVideoCompressionPropertiesKey : [
                            AVVideoAverageBitRateKey : 2300000,],])
    let sourcePixelBufferAttributes = [
                        kCVPixelBufferWidthKey as String: NSNumber(value: Int32(UIScreen.main.bounds.width)),
                        kCVPixelBufferHeightKey as String: NSNumber(value: Int32(UIScreen.main.bounds.height))]
    var videoWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
    var tempURL: URL?
    var isRecording:Bool = false
}
