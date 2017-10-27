//
//  ViewController.swift
//  SpyCamera
//
//  Created by Kassem Bagher on 28/10/17.
//  Copyright © 2017 Kassem Bagher. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController {

    var userCamrera: AVCaptureDevice?
    var cameraCaptureSession = AVCaptureSession()
    var photoOutput: AVCapturePhotoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupCaptureDevice()
        setupPhotoOutput()
        startCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestPermissions()
    }
    
    func caputurePhoto() {
        let captureSettings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: captureSettings, delegate: self)
    }
}

// Setting up variables
extension ViewController {

    // Request access to Camera and Photo Library
    func requestPermissions() {
        // Camera access permission
        AVCaptureDevice.requestAccess(for: .video) { response in}

        // Photo Library access permission
        PHPhotoLibrary.requestAuthorization({
            (status) in
            if status == PHAuthorizationStatus.authorized {
                self.caputurePhoto()
            }})
    }

    func startCaptureSession() {
        cameraCaptureSession.startRunning()
    }

    func setupCaptureSession() {
        // Change capture quality depending on your requirements
        cameraCaptureSession.sessionPreset = AVCaptureSession.Preset.low
    }

    func setupCaptureDevice() {
        /*
         Gets only available front cameras.
         You can change AVCaptureDevice.Position.front to AVCaptureDevice.Position.unspecified
         to get back and front camera
         */
        let availableDevicesSession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front)
        
        let devices = availableDevicesSession.devices
        
        for device in devices {
            userCamrera = device
        }
    }

    func setupPhotoOutput() {
        do {
            let cameraInput = try AVCaptureDeviceInput(device: userCamrera!)
            cameraCaptureSession.addInput(cameraInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            
            cameraCaptureSession.addOutput(photoOutput!)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// Handling caputre delegate
extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Grap captured data
        if let data = photo.fileDataRepresentation() {
            // Convet data into UIImage and save it in user's photo library
            if let capturedImage = UIImage(data: data){
                /*
                 You can change the app's behaviour. i.e. sending the photo to a server
                 */
                UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
            }
        }
    }
}

