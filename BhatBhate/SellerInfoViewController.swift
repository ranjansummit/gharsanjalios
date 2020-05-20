//
//  SellerInfoViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import GoogleMaps
import MessageUI
import SwiftyUserDefaults
class SellerInfoViewController: RootViewController, SellerInfoViewPresentation {
   

    @IBOutlet var sellerInfoImageView: UIImageView!
    @IBOutlet var mapViewContainer: UIView!
    @IBOutlet var separatorView: UIView!
    @IBOutlet var sellerNameLabel: UILabel!
    @IBOutlet var sellerAddressLabel: UILabel!
    @IBOutlet var sellerEmailLabel: UILabel!
    @IBOutlet var sellerPhoneNumberLabel: UILabel!
    @IBOutlet var nameIconView: UIImageView!
    @IBOutlet var phoneIconView: UIImageView!
    @IBOutlet weak var lblBikeInfo: UILabel!
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    fileprivate var presenter:SellerInfoPresenter!
    fileprivate var mapMarker: GMSMarker!
    fileprivate var googleMapView: GMSMapView!
    
    public var vehicleId:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SellerInfoViewController.callSeller))
        sellerPhoneNumberLabel.isUserInteractionEnabled = true
        sellerPhoneNumberLabel.addGestureRecognizer(tapGesture)
       
        let emailTapGesture = UITapGestureRecognizer(target: self, action: #selector(emailSeller))
        sellerEmailLabel.isUserInteractionEnabled = true
        sellerEmailLabel.addGestureRecognizer(emailTapGesture)
        
        presenter = SellerInfoPresenter(viewDelegate: self)
        presenter.fetchSellerInfo(ofVehicleId: vehicleId)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    @objc private func emailSeller(){
        
        let mailComposerViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerViewController, animated: true, completion: nil)
        }else{
            showMailError()
        }
    }
    
    @objc private func callSeller(){
      
        let phone = sellerPhoneNumberLabel.text
        let name = sellerNameLabel.text
        self.showYesNoAlert(title: "Contact Seller", message: "Are you sure want to call \(name ?? "")?"){
            yesNo in
            if yesNo {
                if let url = URL(string: "tel://\(phone!)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sellerInfoImageView.addRoundedCorner(radius: sellerInfoImageView.bounds.height / 2.0)
    }
  
    func setupViews() {
        
        sellerInfoImageView.isHidden = true
        mapViewContainer.isHidden = true
        separatorView.isHidden = true
        sellerNameLabel.isHidden = true
        sellerAddressLabel.isHidden = true
        sellerEmailLabel.isHidden = true
        sellerPhoneNumberLabel.isHidden = true
        nameIconView.isHidden = true
        phoneIconView.isHidden = true
        lblBikeInfo.isHidden = true
        topLine.isHidden = true
        bottomLine.isHidden = true
        
     //   self.title = "Seller Information"
        self.view.backgroundColor = UIColor.white
        self.sellerInfoImageView.contentMode = .scaleAspectFill
    }
    
    func displaySellerInformation(name: String, address: String, email: String, phoneNumber: String, imageUrl: String, bikeName: String, bikePrice: String) {
        
        sellerInfoImageView.isHidden = false
        mapViewContainer.isHidden = false
        separatorView.isHidden = false
        sellerNameLabel.isHidden = false
        sellerAddressLabel.isHidden = false
        sellerEmailLabel.isHidden = false
        sellerPhoneNumberLabel.isHidden = false
        nameIconView.isHidden = false
        phoneIconView.isHidden = false
        lblBikeInfo.isHidden = false
        topLine.isHidden = false
        bottomLine.isHidden = false
        self.sellerNameLabel.text = name
        self.sellerAddressLabel.text = address
        self.sellerEmailLabel.text = email
        self.sellerPhoneNumberLabel.text = "+977" + phoneNumber
        self.sellerInfoImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        self.lblBikeInfo.text = "\(bikeName) @  \(bikePrice)"
    }
    
    func updateSellerLocation(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        getPlacemark(forLocation: location, completionHandler: {
            placemark,error in
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
//                print("sublocality:",placemark?.subLocality ?? "")
//                print("address1:", placemark?.thoroughfare ?? "")
//                print("address2:", placemark?.subThoroughfare ?? "")
//                print("city:",     placemark?.locality ?? "")
//                print("state:",    placemark?.administrativeArea ?? "")
//                print("zip code:", placemark?.postalCode ?? "")
//                print("country:",  placemark?.country ?? "")
                let address1 = placemark?.thoroughfare == nil ? "" : placemark!.thoroughfare! + ", "
                let address2 = placemark?.subThoroughfare == nil ? ""  : placemark!.subThoroughfare! + ", "
                let city = placemark?.locality == nil ?  "" : placemark!.locality! + ", "
                let state = placemark?.administrativeArea == nil ? "" : placemark!.administrativeArea!
                let address = address1  + address2 +  city +  state
                self.sellerAddressLabel.text = address
                
            }
            
        })
        
        let cameraPosition = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12.0)
        
        googleMapView = GMSMapView(frame: mapViewContainer.bounds)
        googleMapView.camera = cameraPosition
        
        mapViewContainer.addSubview(googleMapView)
        
        mapMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        mapMarker.map = googleMapView
    }
    
    func displayError(error: AppError) {
        showAlert(title: "", message: error.localizedDescription){
            self.navigationController?.popViewController(animated: true)
        }
    }
   
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        //21.4796719855459 , 39.1840686276555
        let _ = CLLocation(latitude: 21.4796719855459, longitude: 39.1840686276555)
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let _ = error {
                
                self.hideLoadingIndicator()
                completionHandler(nil, "There is problem with your network. Please try again later.")
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
        
    }
    
}

extension SellerInfoViewController: MFMailComposeViewControllerDelegate{
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        let emailBody = "Dear \(sellerNameLabel.text!),\n\nI saw your bike listed on the Bhatbhate app and I am interested in purchasing it. I want to take a closer look at your vehicle to determine its condition and status.\n\nI would like to arrange a meet-up with you so that I can take a look at the vehicle and chat about its details in person.\n\nPlease contact me at \(Defaults[.userMobile] ?? "") for any queries about the Time and Location.\n\nThank You."
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([sellerEmailLabel.text!])
        mailComposerVC.setSubject("Regarding your bike on sale")
        mailComposerVC.setMessageBody(emailBody, isHTML: false)
        return mailComposerVC
    }
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
   
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
