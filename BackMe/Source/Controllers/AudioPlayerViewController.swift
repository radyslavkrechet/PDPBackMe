//
//  AudioPlayerViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/12/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    @IBOutlet var songLabel: UILabel!
    @IBOutlet var prevButton: UIBarButtonItem!
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var nextButton: UIBarButtonItem!

    private var isPlaying = false
    private var songs = [Song]()
    private var items = [AVPlayerItem]()
    private var player: AVQueuePlayer!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSongs()
        configureItems()
        configureAudioSerssion()
        configureQueuePlayer()
        configureSongLabel()
        registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        try! AVAudioSession.sharedInstance().setActive(false)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        if keyPath == "currentItem" {
            let currentItem = player.items().first

            if let currentItem = currentItem {
                let index = items.index(of: currentItem)

                nextButton.isEnabled = index == songs.count - 1 ? false : true
                prevButton.isEnabled = index == 0 ? false : true
                configureSongLabel()
            } else {
                player.insert(items.last!, after: nil)
                player.seek(to: CMTimeMake(value: 0, timescale: 1))
                isPlaying = !isPlaying
                player.pause()
                playButton.title = "Play"
            }
        }
    }
    
    // MARK: - Configuration
    
    private func configureSongs() {
        let artist = Artist(name: "Royal Blood")
        
        songs.append(Song(artist: artist, title: "Lights Out (Preview)", url: songUrl(withId: 317531624)))
        songs.append(Song(artist: artist, title: "Figure It Out", url: songUrl(withId: 156693775)))
        songs.append(Song(artist: artist, title: "Come On Over", url: songUrl(withId: 145938948)))
        songs.append(Song(artist: artist, title: "Little Monster", url: songUrl(withId: 134041449)))
        songs.append(Song(artist: artist, title: "I Only Lie When I Love You (Preview)", url: songUrl(withId: 327169029)))
    }
    
    private func songUrl(withId id: Int) -> URL {
        let string = "http://api.soundcloud.com/tracks/\(id)/stream?client_id=SwFQlevLm62tWOZuOHC866yWHTUoIFOo"
        return URL(string: string)!
    }
    
    private func configureItems() {
        songs.forEach { song in
            items.append(AVPlayerItem(url: song.url))
        }
    }
    
    private func configureAudioSerssion() {
        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)
    }
    
    private func configureQueuePlayer() {
        player = AVQueuePlayer(items: items)
        player.addObserver(self, forKeyPath: "currentItem", options: [.new] , context: nil)
    }
    
    private func configureSongLabel() {
        let index = songs.count - player.items().count
        
        let song = songs[index]
        songLabel.text = "\(song.artist.name) - \(song.title)"
    }
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    @objc func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                
                return
        }
        
        if type == .began {
            isPlaying = !isPlaying
            playButton.title = "Play"
        }
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                
                return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == .headphones {
                    isPlaying = !isPlaying
                    playButton.title = "Play"
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @IBAction func prevButtonPressed(_ sender: UIBarButtonItem) {
        let index = songs.count - player.items().count - 1
        
        if index >= 0 {
            let currentItem = player.items().first!
            let newItem = items[index]
            
            player.insert(newItem, after: currentItem)
            player.remove(currentItem)
            player.insert(currentItem, after: newItem)
            player.seek(to: CMTimeMake(value: 0, timescale: 1))
            configureSongLabel()
        }
    }
    
    @IBAction func playButtonPressed(_ sender: UIBarButtonItem) {
        isPlaying = !isPlaying
        
        if !isPlaying {
            sender.title = "Play"
            player.pause()
        } else {
            sender.title = "Pause"
            player.play()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
        player.advanceToNextItem()
        player.seek(to: CMTimeMake(value: 0, timescale: 1))
    }
}
