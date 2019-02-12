//
//  PhotoUploaderViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/15/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit

class PhotoUploaderViewController: UIViewController,
URLSessionTaskDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var uploadButton: UIBarButtonItem!
    
    private var imageUrl: URL?
    private var uploadTask: URLSessionUploadTask?
    
    private var imageName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        
        return dateFormatter.string(from: Date()).appending(".png")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if uploadTask == nil && imageUrl == nil {
            clearUserInterface()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        uploadTask?.cancel()
    }
    
    // MARK: - Configuration
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func clearUserInterface() {
        imageView.image = nil
        activityIndicator.stopAnimating()
        uploadButton.isEnabled = false
    }

    private func uploadImage() {
        activityIndicator.startAnimating()
        uploadButton.isEnabled = false

        uploadTask = NetworkService.uploadImage(withName: imageName, url: imageUrl!, sessionDelegate: self)
    }
    
    // MARK: - Actions
    
    @IBAction func chooseButtonPressed(_ sender: UIBarButtonItem) {
        presentImagePicker()
    }
    
    @IBAction func uploadButtonPressed(_ sender: UIBarButtonItem) {
        uploadImage()
    }

    // MARK: - URLSessionTaskDelegate
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            self.imageUrl = nil
            self.uploadTask = nil
            
            let applicationDelegate = UIApplication.shared.delegate as! AppDelegate
            applicationDelegate.completionHandler!()
            applicationDelegate.completionHandler = nil
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.imageUrl = nil
            self.uploadTask = nil
            
            self.clearUserInterface()
        }
    }

    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL

        uploadButton.isEnabled = true
        imageView.image = image

        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
