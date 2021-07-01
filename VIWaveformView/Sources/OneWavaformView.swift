//
//  OneWavaformView.swift
//  VIWaveformView
//
//  Created by roni on 2021/7/1.
//  Copyright © 2021 Vito. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class OneWaveformView: UIView {
    public var operationQueue: DispatchQueue?
    fileprivate(set) var actualWidthPerSecond: CGFloat = 0
    private var asset: AVAsset
    private var timeRange: CMTimeRange
    public init(frame: CGRect, asset: AVAsset, timeRange: CMTimeRange) {
        self.asset = asset
        self.timeRange = timeRange
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        addSubview(nodeView)
        nodeView.strokeColor = .red
        nodeView.translatesAutoresizingMaskIntoConstraints = false
        nodeView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        nodeView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nodeView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nodeView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    public func updateWaveformTimeRange(_ timeRange: CMTimeRange) {
        self.timeRange = timeRange
    }

    public func loadVoice() {
        if frame.width != 0 {
            let duration = timeRange.duration.seconds
            actualWidthPerSecond = frame.width / CGFloat(duration)
            _ = loadVoice(from: asset, timeRange: timeRange) { error in
                if let err = error {
                    print("\(err.localizedDescription)")
                }
            }
        } else {
            print("view's width is 0, we can't caculate actualWidthPerSecond.")
        }
    }

    public let nodeView: VIWaveformNodeView = VIWaveformNodeView(frame: .zero)
}

extension OneWaveformView {
    func loadVoice(from asset: AVAsset, timeRange: CMTimeRange, completion: @escaping ((Error?) -> Void)) -> Cancellable {
        let cancellable = Cancellable()
        asset.loadValuesAsynchronously(forKeys: ["duration", "tracks"], completionHandler: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            var error: NSError?
            let tracksStatus = asset.statusOfValue(forKey: "tracks", error: &error)
            if tracksStatus != .loaded {
                completion(error)
                return
            }
            let durationStatus = asset.statusOfValue(forKey: "duration", error: &error)
            if durationStatus != .loaded {
                completion(error)
                return
            }

            let operation = VIAudioSampleOperation(widthPerSecond: strongSelf.actualWidthPerSecond)
            if let queue = strongSelf.operationQueue {
                operation.operationQueue = queue
            }

            func updatePoints(with audioSamples: [VIAudioSample]) {
                var points: [Float] = []
                if let audioSample = audioSamples.first {
                    points = audioSample.samples.map({ (sample) -> Float in
                        return Float(sample / 20000.0)
                    })
                }
                DispatchQueue.main.async {
                    strongSelf.nodeView.updateWaveformPoint(points)
                }
            }

            let operationTask = operation.loadSamples(from: asset, timeRange: timeRange, progress: { (audioSamples) in
                updatePoints(with: audioSamples)
            }, completion: { (audioSamples, error) in
                guard let audioSamples = audioSamples else {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                    return
                }

                updatePoints(with: audioSamples)

                DispatchQueue.main.async {
                    completion(nil)
                }
            })
            cancellable.cancelBlock = {
                operationTask?.cancel()
            }
        })
        cancellable.cancelBlock = {
            asset.cancelLoading()
        }
        return cancellable
    }
}
