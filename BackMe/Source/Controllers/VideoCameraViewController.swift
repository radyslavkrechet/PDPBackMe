//
//  VideoCameraViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/14/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit
import MobileCoreServices

class VideoCameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var captureVideoButton: UIButton!
    @IBOutlet var saveToCameraRollVideoButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var timer: Timer?
    
    private var videoUrl: URL!
    private var backgroundTask = UIBackgroundTaskIdentifier.invalid
    
    // MARK: - Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Configuration
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = [String(kUTTypeMovie)];
        imagePickerController.videoExportPreset = "AVAssetExportPresetHighestQuality"
        imagePickerController.videoMaximumDuration = 30.0
        present(imagePickerController, animated: true, completion: nil)
    }

    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }

    @objc func saveVideoToCameraRoll() {
        UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path,
                                            self,
                                            #selector(video(videoPath:didFinishSavingWithError:contextInfo:)),
                                            nil)
    }

    @objc func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        captureVideoButton.isEnabled = true
        saveToCameraRollVideoButton.isEnabled = true
        activityIndicator.stopAnimating()

        if backgroundTask != .invalid {
            endBackgroundTask()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func captureVideoButtonPressed(_ sender: UIButton) {
        presentImagePicker()
    }
    
    @IBAction func saveToCameraRollButtonPressed(_ sender: UIButton) {
        captureVideoButton.isEnabled = false
        saveToCameraRollVideoButton.isEnabled = false
        activityIndicator.startAnimating()
        
        timer = Timer.scheduledTimer(timeInterval: 5.0,
                                     target: self,
                                     selector: #selector(saveVideoToCameraRoll),
                                     userInfo: nil,
                                     repeats: false)
        
        beginBackgroundTask()
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        saveToCameraRollVideoButton.isEnabled = true
        videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
