//
//  QRReaderViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/17/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyUserDefaults
class QRReaderViewController: RootViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession:AVCaptureSession?
    var captureDevice:AVCaptureDevice?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    // var qrCodeFrameView:UIView?
    @IBOutlet weak var qrCodeFrame: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    //    self.title = "Scan"
    }
    
    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = qrCodeFrame.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch  status {
        case .denied:
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
        case .authorized:
            startScanningQRCode()
        case .notDetermined:
            self.startScanningQRCode()
            AVCaptureDevice.requestAccess(for: .video){
                authorized in
                if authorized {
                    //print(authorized)
                }else {
                    self.captureSession?.stopRunning()
                    DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        default:
            showAlert(title: "", message: "Could not open camera."){
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    func startScanningQRCode() {
        
        // Physical capture device
         captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            captureSession = AVCaptureSession()
            
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            DispatchQueue.main.async {
                self.qrCodeFrame.layer.addSublayer(self.videoPreviewLayer!)
            }
            captureSession?.startRunning()
            
        } catch {
            print(error.localizedDescription)
            
            self.showAlert(title: "", message: CustomError.standard.localizedDescription)
        }
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            captureSession?.stopRunning()
            
            DispatchQueue.main.async {
                
                let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: CreditPurchaseConfirmationViewController.stringIdentifier) as! CreditPurchaseConfirmationViewController
                vc.scannedQRValues = metadataObj.stringValue
                vc.currentPurchaseType = .qr
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
