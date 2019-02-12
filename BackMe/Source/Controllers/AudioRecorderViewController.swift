//
//  AudioRecorderViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/12/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderViewController: UITableViewController, AVAudioPlayerDelegate {
    private var isRecording = false
    private var recorder: AVAudioRecorder!
    private var player: AVAudioPlayer!
    
    private var documentDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    private var audioPath: URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        
        let audioName = dateFormatter.string(from: Date()).appending(".m4a")
        
        return documentDirectory.appendingPathComponent(audioName)
    }
    private var contentsOfDocumentDirectory: [URL] {
        return try! FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAudioSerssion()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player?.stop()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        try! AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Configuration
    
    private func configureAudioSerssion() {
        try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] allowed in
            DispatchQueue.main.async {
                if !allowed {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func recordButtonPressed(_ sender: UIButton) {
        isRecording = !isRecording
        
        if isRecording {
            sender.setTitle("Stop", for: .normal)
            recorder = try! AVAudioRecorder(url: audioPath, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC])
            recorder.record()
        } else {
            sender.setTitle("Record", for: .normal)
            recorder.stop()
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentsOfDocumentDirectory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let url = contentsOfDocumentDirectory[indexPath.row]
        cell.textLabel!.text = url.lastPathComponent

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let url = contentsOfDocumentDirectory[indexPath.row]
            try! FileManager.default.removeItem(at: url)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let url = contentsOfDocumentDirectory[indexPath.row]
        player = try! AVAudioPlayer(contentsOf: url)
        player.delegate = self
        player.play()
        
        return indexPath
    }

    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let indexPath = tableView.indexPathForSelectedRow!
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
