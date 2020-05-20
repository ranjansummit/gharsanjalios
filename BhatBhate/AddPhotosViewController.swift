
//
//  AddPhotosViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 7/19/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import Fusuma
import AVFoundation
import Photos
import SwiftyUserDefaults
class AddPhotosViewController: RootViewController {

    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    var image1:UIImage?
    var image2:UIImage?
    var image3:UIImage?
    var image4:UIImage?
    
    var tapGesture1: UITapGestureRecognizer!
    var tapGesture2: UITapGestureRecognizer!
    var tapGesture3: UITapGestureRecognizer!
    var tapGesture4: UITapGestureRecognizer!
    
    var selectedImage: UITapGestureRecognizer!
    
    var editBike:Bike?
    override func viewDidLoad() {
        super.viewDidLoad()

        tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(AddPhotosViewController.firstImageTapped))
        imageView1.addGestureRecognizer(tapGesture1)
        imageView1.isUserInteractionEnabled = true
        tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(AddPhotosViewController.firstImageTapped))
        imageView2.addGestureRecognizer(tapGesture2)
        imageView2.isUserInteractionEnabled = true
        
        tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(AddPhotosViewController.firstImageTapped))
        imageView3.addGestureRecognizer(tapGesture3)
        imageView3.isUserInteractionEnabled = true
        
        tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(AddPhotosViewController.firstImageTapped))
        imageView4.addGestureRecognizer(tapGesture4)
        imageView4.isUserInteractionEnabled = true
        
        if let imageData1 =  GlobalVar.sharedInstance.answer["front_side_image"] as? Data {
            if let img1 = UIImage(data: imageData1){
                self.imageView1.image = img1
                self.image1 = img1
            }
        }
        
        if let imageData2 =  GlobalVar.sharedInstance.answer["left_side_image"] as? Data {
            if let img = UIImage(data: imageData2){
                self.imageView2.image = img
                self.image2 = img
            }
        }
        
        if let imageData3 =  GlobalVar.sharedInstance.answer["right_side_image"] as? Data {
            if let img = UIImage(data: imageData3){
                self.imageView3.image = img
                self.image3 = img
            }
        }
        
        
        if let imageData4 =  GlobalVar.sharedInstance.answer["back_side_image"] as? Data {
            if let img = UIImage(data: imageData4){
                self.imageView4.image = img
                self.image4 = img
            }
        }
        
        
        guard let bike = editBike, let images = bike.imageURL else {
            GlobalVar.sharedInstance.answer["seller_image"] = Defaults[.userPicURL]
            return
        }
        GlobalVar.sharedInstance.answer["seller_image"] = self.editBike?.sellerImage
            
        for (index , image) in images.enumerated() {
            downloadedFrom(url:URL(string: image.formattedURL())! , index: index){
                index, image in
                switch index {
                case 0:
                    self.imageView1.image = image
                    self.image1 = image
                case 1:
                    self.imageView2.image = image
                    self.image2 = image
                case 2:
                    self.imageView3.image = image
                    self.image3 = image
                default:
                    self.imageView4.image = image
                    self.image4 = image
                }
    
                self.imageView1.contentMode = .scaleAspectFill
                self.imageView1.layer.masksToBounds = true
                
                self.imageView2.contentMode = .scaleAspectFill
                self.imageView2.layer.masksToBounds = true
                
                self.imageView3.contentMode = .scaleAspectFill
                self.imageView3.layer.masksToBounds = true
                
                self.imageView4.contentMode = .scaleAspectFill
                self.imageView4.layer.masksToBounds = true
            }
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        if Defaults[.promotionMode]{
            if !Defaults[.preview]{
            self.tabBarController?.tabBar.items?[2].isEnabled = false
            self.tabBarController?.tabBar.items?[2].badgeValue = nil
            }
        }else{
            self.tabBarController?.tabBar.items?[2].isEnabled = true
        }
    }

    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied. Please change the camera access grant in Settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                        // Handle
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(url)
                }
            }
        })
        
        present(alertController, animated: true)
    }
    
    @objc func firstImageTapped(sender : UITapGestureRecognizer){

        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized,.notDetermined:
            let fusuma = FusumaViewController()
            fusuma.delegate = self
            fusuma.cropHeightRatio = 0.8
            selectedImage = sender
            self.present(fusuma, animated: true, completion: nil)
        default:
             presentCameraSettings()
        }
    
    }
    
    
    func downloadedFrom(url: URL,index:Int, whenFinished:((Int,UIImage)->())?) {
       // contentMode = mode
        print(url)
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                whenFinished!(index,image)
               
            }
            }.resume()
    }
    
    @IBAction func actionPreview(_ sender: UIBarButtonItem) {
        guard let img1 = self.image1 , let img2 = self.image2, let img3 = image3, let img4 = image4 else {
            showAlert(title: "", message: "Please select 4 images")
            return
        }
        let images = [img1,img2,img3,img4]
        GlobalVar.sharedInstance.answer["images"] = images
        
        print(GlobalVar.sharedInstance.answer)
        let bikeModel = Bike(dictBike: GlobalVar.sharedInstance.answer)
        let previewVC = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: "BikePreview") as! BikePreviewViewController
        previewVC.bike = bikeModel
        previewVC.previewState = BikePreviewState.sellPreview
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
}

extension AddPhotosViewController:FusumaDelegate{
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        let data = image.jpegData(compressionQuality: 0.1)!
        
        switch selectedImage {
        case self.tapGesture1:
            imageView1.image = image
            self.image1 = image
             GlobalVar.sharedInstance.answer["front_side_image"] = data
        case self.tapGesture2:
            imageView2.image = image
            self.image2 = image
             GlobalVar.sharedInstance.answer["left_side_image"] = data
        case self.tapGesture3:
            imageView3.image = image
            self.image3 = image
            GlobalVar.sharedInstance.answer["right_side_image"] = data
        default:
            imageView4.image = image
            self.image4 = image
            GlobalVar.sharedInstance.answer["back_side_image"] = data
        }
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
