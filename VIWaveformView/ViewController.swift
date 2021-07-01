//
//  ViewController.swift
//  VIWaveformView
//
//  Created by Vito on 2018/8/11.
//  Copyright © 2018 Vito. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(red:0.10, green:0.14, blue:0.29, alpha:1.00)
        
        setupWaveformView()
        view.addSubview(waveformView)
        
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        waveformView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        waveformView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        waveformView.topAnchor.constraint(equalTo: view.topAnchor, constant: 65).isActive = true
        waveformView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        waveformView.layoutIfNeeded()
        if let url = Bundle.main.url(forResource: "Moon River", withExtension: "mp3") {
            let asset = AVAsset.init(url: url)
            _ = waveformView.loadVoice(from: asset, timeRange: CMTimeRange(start: .zero, duration: asset.duration), completion: { (asset) in
            })
        }

        oneWaveformView()
    }

    func oneWaveformView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        scrollView.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 65).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 800).isActive = true

        if let url = Bundle.main.url(forResource: "Moon River", withExtension: "mp3") {
            let asset = AVAsset.init(url: url)
            let oView = OneWaveformView(frame: .zero, asset: asset, timeRange: CMTimeRange(start: .zero, duration: asset.duration))
            oneView = oView
            containerView.addSubview(oView)
            oView.translatesAutoresizingMaskIntoConstraints = false
            oView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            oView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            oView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            oView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        oneView?.loadVoice()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var waveformView: VIWaveformView!
    func setupWaveformView() {
        waveformView = VIWaveformView()
        waveformView.backgroundColor = UIColor(red:0.10, green:0.14, blue:0.29, alpha:1.00)
        waveformView.minWidth = UIScreen.main.bounds.width
        
        waveformView.waveformNodeViewProvider = BasicWaveFormNodeProvider(generator: { () -> NodePresentation in
            let view = VIWaveformNodeView()
            view.waveformLayer.strokeColor = UIColor(red:0.86, green:0.35, blue:0.62, alpha:1.00).cgColor
            return view
        }())
    }

    let scrollView = UIScrollView()
    var oneView: OneWaveformView?
}

