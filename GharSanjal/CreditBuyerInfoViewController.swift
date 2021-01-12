//
//  CreditBuyerInfoViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/11/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import SDWebImage
import SwiftyUserDefaults


class CreditBuyerInfoViewController: RootViewController,GMSMapViewDelegate,CLLocationManagerDelegate {

    public var info:CreditNotification!
    
    @IBOutlet weak var labelCreditString: UILabel!
    @IBOutlet var buyerImageView: UIImageView!
    @IBOutlet var buyerNameLabel: UILabel!
    @IBOutlet var buyerAddressLabel: UILabel!
    @IBOutlet var viewLocationButton: UIButton!
    @IBOutlet var creditQuantityLabel: UILabel!
    @IBOutlet var acceptRequestButton: UIButton!
    

    public var onCreditRequestAccepted: (()->())?
    fileprivate var locationManager = CLLocationManager()
    fileprivate var myLocation:CLLocation?
    fileprivate var locationISUpdated = false
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        buyerImageView.addRoundedCorner(radius: buyerImageView.frame.width / 2)
    }
    
    func setupViews() {
        
    //    self.title = "Credit Request Information"
        buyerNameLabel.text = info.buyerName

        if let image = URL(string:((info.buyerImage ?? "").formattedURL())) {
            buyerImageView.contentMode = .scaleAspectFill
        buyerImageView.sd_setImage(with: image)
        }
        buyerAddressLabel.text = ""
        creditQuantityLabel.text = "\(info.creditQuantity ?? 0)"
        labelCreditString.text = (info.creditQuantity ?? 0) > 1 ? "Credits" : "Credit"
        viewLocationButton.addTarget(self, action: #selector(onViewLocationButtonTap), for: .touchUpInside)
        if info.status == .sent {
        acceptRequestButton.setTitle("ACCEPT REQUEST", for: .normal)
            acceptRequestButton.isEnabled = true
        }else if info.status == .accepted {
            acceptRequestButton.setTitle("REQUEST ACCEPTED", for: .normal)
            acceptRequestButton.isEnabled = false
        }
        acceptRequestButton.addTarget(self, action: #selector(onAcceptRequestButtonTap), for: .touchUpInside)
        
        guard   let latitude = info.buyerLatitude, let longitude = info.buyerLongitude else {
        buyerAddressLabel.text =  "Address not available"
            return
        }
        
        showLoadingIndicator()
        getPlacemark(forLocation:CLLocation(latitude:latitude,longitude:longitude)  , completionHandler: {
            placemark , k in
            
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
                self.buyerAddressLabel.text = address
                
            }
            
            
           
        })
       
        
    }
    
    @objc func onAcceptRequestButtonTap() {
        
        self.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeCreditNotificationStatus(response: 1, notificationId: info.id!, filter: "seller"), onSuccess: { (statusCode, data) in
            
            self.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent  = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.showAlert(title: "", message: "You have accepted buyer's request for credit. He/she will be waiting for you to come."){
                    self.onCreditRequestAccepted?()
                        self.navigationController?.popViewController(animated: true) 
                    }
                    self.acceptRequestButton.isEnabled = false
                    self.acceptRequestButton.alpha = 0.6
                    
                    
                    
                } else {
                    
                    self.showAlert(title: "", message: CustomError.standard.localizedDescription)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                
                self.showAlert(title: "", message: message)
            }
            
        }) { (error) in
            
            self.hideLoadingIndicator()
            self.showAlert(title: "", message: error.localizedDescription)
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error.localizedDescription)
//        print("error code\(error as NSError).code)")
        self.hideLoadingIndicator()
        self.showAlert(title: "", message: "Sorry! We cannot determine your location at this time. Please allow this app to use Location Services from settings.")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        hideLoadingIndicator()
        if self.locationISUpdated {
            return
        }
        if let currentLocation = locations.last {
            locationISUpdated = true
            if let latitude = info.buyerLatitude, let longitude = info.buyerLongitude {
                let loc = currentLocation
                let directVC = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: ShopDirectionViewController.stringIdentifier) as! ShopDirectionViewController
                directVC.sourcePosition = loc.coordinate
                directVC.destinationPosition = CLLocationCoordinate2D(latitude:
                    latitude, longitude: longitude)
                directVC.destinationName = info.buyerName
                directVC.destinationMobile = info.buyerMobileNumber
                self.navigationController?.pushViewController(directVC, animated: true)
            } else {
                self.showAlert(title: "", message: "Cannot determine buyer's location at this time. Try again later")
            }
            
        }
    }
    
    
    @objc func onViewLocationButtonTap() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
        locationISUpdated = false
         showLoadingIndicator()
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

    
extension Bool {
 mutating func toggle() {
        self = !self
    }
}

