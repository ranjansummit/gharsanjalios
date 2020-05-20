//
//  CameraApertureViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 7/19/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import AVFoundation
class CameraApertureViewController: RootViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var camera: UIView!
    var captureImage : ((_ image:UIImage?, _ orientation:UIDeviceOrientation)->())?
    var session = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var orientation:UIDeviceOrientation = .portrait
    var imageOrientation:AVCaptureVideoOrientation!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main){
            notification in
            switch UIDevice.current.orientation {
            case .landscapeRight:
              //  print("landscape right")
                self.orientation = .landscapeRight
            case .landscapeLeft:
                //print("landscape left")
                self.orientation = .landscapeRight
            case  .portraitUpsideDown:
                //print("Portrait upside down")
                self.orientation = .portraitUpsideDown
            case .portrait:
                self.orientation = .portrait
                //print("portrait normal")
            default:
                print("other")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == AVAuthorizationStatus.denied {
            showAlert(title: "Error", message: "Please allow camera action for this app in phone settings."){
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            // Fallback on earlier versions
                            
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
            return
        }
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.medium

        session.sessionPreset = AVCaptureSession.Preset.medium

        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        
        captureVideoPreviewLayer.frame = camera.bounds
        camera.layer.addSublayer(captureVideoPreviewLayer)
        
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: device!)
            session.addInput(input)
            session.addOutput(stillImageOutput)
            session.startRunning()
        }catch (let error){
            print(error.localizedDescription)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let screenSize = camera.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: camera).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: camera).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
        
                    // just ignore
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
         UIDevice.current.orientation.isLandscape ? print("landscape") : print("portrait")

    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
       // self.captureImage!(nil, self.orientation)
    }
    
    
    
    @IBAction func clickButton(_ sender: UIButton) {
        
        if let videoConnection = stillImageOutput.connection(with: AVMediaType.video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageref = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                  print(UIDevice.current.orientation.rawValue)
                   // let image = UIImage(cgImage: cgImageref!)
                    var imageOrientation:UIImage.Orientation = .up
                    //portrait : right landscape: up
                    switch UIDevice.current.orientation {
                    case .landscapeRight:
                       imageOrientation = .down
                        
                    case .landscapeLeft:
                        imageOrientation = .up
                        
                    case  .portraitUpsideDown:
                      //  print("Portrait upside down")
                        imageOrientation = .rightMirrored
                    case .portrait:
                        imageOrientation = .right
                        //print("portrait normal")
                    default:
                        print("other")
                    }
                    let image = UIImage(cgImage: cgImageref!, scale: 1.0, orientation: imageOrientation)
                    self.captureImage!(image, self.orientation)
            self.dismiss(animated: true, completion: nil)
              
                }
                
            })
            
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
