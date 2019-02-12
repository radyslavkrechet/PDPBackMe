//
//  PictureInPictureViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/13/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAudioSerssion()
        configureVideoPlayer()
    }
    
    // MARK: - Configuration
    
    private func configureAudioSerssion() {
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
    }
    
    private func configureVideoPlayer() {
        let string = "https://p-events-delivery.akamaized.net/17qopibbefvoiuhbsefvbsefvopihb06/m3u8/hls_vod_mvp.m3u8"
        let url = URL(string: string)!
        let player = AVPlayer(url: url)
        
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.view.frame = view.frame
        
        addChild(playerController)
        view.addSubview(playerController.view)
    }
}
