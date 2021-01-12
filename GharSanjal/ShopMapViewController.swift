//
//  ShopMapViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Starscream
import SwiftyUserDefaults
import SwiftyJSON
class ShopMapViewController: RootViewController,ShopMapViewPresentation, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var infoView: UIView!
    @IBOutlet var infoViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userAddressLabel: UILabel!
    @IBOutlet var emailAddressLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var getDirectionButton: UIButton!
    @IBOutlet var closeImageView: UIImageView!
    @IBOutlet weak var exportToGoogleMap: UIButton!
    
    private var googleMapView: GMSMapView!
    private var myCurrentLocation:CLLocation?
    fileprivate var locationManager = CLLocationManager()
    private lazy var creditRequestPopup = PurchaseCreditPopup()
    
    var shopCreditSellers: [CreditSellerMarker] = []
    var bikeCreditSellers: [CreditSellerMarker] = []
    
    fileprivate var presenter: ShopMapViewPresenter!
    fileprivate var activeMarker: GMSMarker?
    fileprivate var mapISSetup = false
    var zoomLevel:Float = 8.0
    let socket = Constants.webSocketURL//WebSocket(url: URL(string: "ws://staging.andmine.com:7979/")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ShopMapViewPresenter(controller: self)
       // print("******userid******")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        setupWebSocket()
    }
    
    func setupViews() {
       // self.title = "Credit Shops"
        
        userImageView.addRoundedCorner(radius: 35)
        getDirectionButton.backgroundColor = AppTheme.Color.primaryRed
        exportToGoogleMap.backgroundColor = AppTheme.Color.primaryRed
        exportToGoogleMap.setTitleColor(AppTheme.Color.white, for: .normal)
        getDirectionButton.setTitle("GET DIRECTION", for: .normal)
        getDirectionButton.setTitleColor(AppTheme.Color.white, for: .normal)
        getDirectionButton.addTarget(self, action: #selector(onGetDirectionButtonTap), for: .touchUpInside)
        
        hideInfoView(shouldAnimate: false)
        
        let cameraPosition =  GMSCameraPosition.camera(withLatitude: 27.700769, longitude:85.300140, zoom: zoomLevel)
        
        googleMapView = GMSMapView(frame: view.bounds)
        googleMapView.delegate = self
        googleMapView.camera = cameraPosition
        
        view.addSubview(googleMapView)
        view.bringSubviewToFront(infoView)
        
        closeImageView.contentMode = .scaleAspectFit
        closeImageView.tintColor = AppTheme.Color.textGrey
        closeImageView.image = #imageLiteral(resourceName: "ic_swipe_cross").withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
       
        setupUserLocation()
    }
    
    private func setupWebSocket(){
        socket.delegate = self
        socket.connect()
    }
    
    @IBAction func actionExportToGoogleMap(_ sender: UIButton) {
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!){
             if let marker = activeMarker as? CreditSellerMarker {
                let url = URL(string:
                    "comgooglemaps://?saddr=&daddr=\(marker.sellerInfo.latitude!),\(marker.sellerInfo.longitude!)&directionsmode=driving")!
                UIApplication.shared.openURL(url)
            }

        }else {
            showAlert(title: "", message: "Could not find Google Maps app.")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      //  print("socket disconnet in view will disappear")
        socket.disconnect()
    }
    
    func showMessage(message: String) {
        self.showAlert(title: "", message: message)
    }
    
    // Helper function to setup location
    func setupUserLocation() {
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestLocation()
        
        // self.showLoadingIndicator()
    }
    
    func showSellerInfo(name:String,address:String,email:String,phoneNumber:String, imageUrl:String) {
        
        userNameLabel.text = name
        userAddressLabel.text = address
        emailAddressLabel.text = email
        phoneNumberLabel.text = phoneNumber
        userImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        
        if infoView.isHidden {
            
            infoView.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                self.infoViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.zoomLevel = position.zoom
    }
    
    func showMapView(with location: CLLocation) {
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        googleMapView.camera = camera
    }
    
    func showCreditSellerMarkersInMap(markers: [CreditSellerMarker], isShop:Bool) {
        googleMapView.clear()
        var combinedMarkers:[CreditSellerMarker] = []
        if isShop {
            shopCreditSellers = markers
        }else {
            bikeCreditSellers = markers
        }
        combinedMarkers = bikeCreditSellers + shopCreditSellers
        
        for marker in combinedMarkers {
            marker.map = googleMapView
            // marker.appearAnimation = .pop
        }
    }
    
    func showCreditRequestPopup(sellerId: Int,sellerName:String) {
        
        creditRequestPopup.setupDefaultConfiguration()
        creditRequestPopup.headerLabel.text = "Contact \(sellerName)"
        
        creditRequestPopup.closeButtonAction = {
            PopupContainer.hide()
        }
        
        creditRequestPopup.requestButtonAction = { [unowned self] in
            
            self.presenter.requestSellerForCredit(amount: self.creditRequestPopup.creditQuantity, sellerId: sellerId)
            PopupContainer.hide()
        }
        
        PopupContainer.show(popup: creditRequestPopup, popupSize: creditRequestPopup.defaultSize)
    }
    
    func hideInfoView(shouldAnimate:Bool) {
        
        if shouldAnimate {
            
            infoView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.infoViewBottomConstraint.constant = -345
                self.view.layoutIfNeeded()
            }, completion: { (isComplete) in
                
                self.infoView.isHidden = isComplete
            })
        } else {
            infoViewBottomConstraint.constant = -345
            infoView.isHidden = true
        }
        
    }
    
    func showError(error: AppError) {
        self.showAlert(title: "", message: error.localizedDescription){
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onGetDirectionButtonTap() {
        
        if let marker = activeMarker as? CreditSellerMarker {
            
            let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: ShopDirectionViewController.stringIdentifier) as! ShopDirectionViewController
            
            let sourceLocation = presenter.getUserCurrentLocation()
            let destinationLocation = CLLocationCoordinate2D(latitude: marker.sellerInfo.latitude ?? 0.0, longitude: marker.sellerInfo.longitude ?? 0.0)
            
            vc.sourcePosition = sourceLocation
            vc.destinationPosition = destinationLocation
            vc.destinationName = marker.sellerInfo.name ?? ""
            vc.destinationMobile = marker.sellerInfo.mobile ?? ""
            vc.isFromShopCredit = true
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func onHideInfoButtonTap(_ sender: Any) {
        hideInfoView(shouldAnimate: true)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let sellerMarker = marker as? CreditSellerMarker {
            
            self.activeMarker = marker
            
            let sellerInfo = sellerMarker.sellerInfo
            switch sellerInfo.type {
                
            case .user:
                guard let sellerID = sellerInfo.id else {
                    showMessage(message: "Could not find the seller detail.Please try again later")
                    return true
                }
                self.showCreditRequestPopup(sellerId: sellerID,sellerName: sellerInfo.name ?? "")
            case .shop:
                
                let sellerName = sellerInfo.name ?? ""
                let sellerAddress = sellerInfo.location ?? ""
                let sellerEmail = sellerInfo.email ?? ""
                let sellerPhone = sellerInfo.mobile ?? ""
                let sellerImageUrl = sellerInfo.imageUrl ?? ""
                
                showSellerInfo(name: sellerName, address: sellerAddress, email: sellerEmail, phoneNumber: sellerPhone, imageUrl: sellerImageUrl)
            }
        }
        
        return true
    }
    
    
    // MARK:- CoreLocation Delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied || status == .restricted {
            self.showAlert(title: "Location Denied", message: "Please allow this app to use Location Services from settings."){
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _ = Defaults[.accessToken] else {
            return
        }
        if let currentLocation = locations.first {
          //  print("***********************")
            self.myCurrentLocation = currentLocation
            print(currentLocation)
           //  UP#<userId>#<available_credit>#<lat>#<lng>
            let up = "UP#\(String(describing: Defaults[.userId]!))#\(String(describing: Defaults[.userCreditCount]))#\(currentLocation.coordinate.latitude)#\(currentLocation.coordinate.longitude)"
            socket.write(string: up, completion: {

            })
            if !mapISSetup{
                mapISSetup = true
                 showMapView(with: myCurrentLocation!)
                 self.presenter.setupMap(forLocation: currentLocation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error.localizedDescription)
//        print("error code\(error as NSError).code)")
        self.hideLoadingIndicator()
        self.showAlert(title: "", message: "Sorry! We cannot determine your location at this time. Please allow this app to use Location Services from settings.")
    }
    
}

extension ShopMapViewController : WebSocketDelegate {

//    func uploadMyLocation(){
//        guard let myLocation = self.myCurrentLocation else {
//            return
//        }
//        socket.write(string: "UP#\(String(describing: Defaults[.userId]!))#\(String(describing: Defaults[.userName]!))#\(myLocation.coordinate.latitude)#\(myLocation.coordinate.longitude)", completion: {
//            print("web socket write up")
//        })
   // }
    
    func websocketDidConnect(socket: WebSocketClient) {
      //  print("web socket did connected")
        guard let myLocation = self.myCurrentLocation, let _ = Defaults[.accessToken] else {
            return
        }
        
        //JOIN#<type>#<userId>#<userName>#<email>#<mobile>#<shop>#available_credit
        let joinString = "JOIN#MBL#\(Defaults[.userId]!)#\(Defaults[.userName]!)#\(Defaults[.userEmail] ?? "NA")#\(Defaults[.userMobile] ?? "NA")#0#\(Defaults[.userCreditCount])"
        socket.write(string: joinString , completion: {
        })
        
        socket.write(string: "SEARCH#\(myLocation.coordinate.latitude)#\(myLocation.coordinate.longitude)", completion: {
            
        })
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
       // print("web socket did disconnect ")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
       // print("web socket did receive message")
        if text == "PING" {
            socket.write(string: "PONG")
            guard let myLocation = self.myCurrentLocation else {
                return
            }
            locationManager.requestLocation()
            let search = "SEARCH#\(myLocation.coordinate.latitude)#\(myLocation.coordinate.longitude)"
          //  print("search == \(search)")
            socket.write(string: search , completion: {
                print("web socket write search in did receice message")
            })
        }else {
            
            let encodeString = (text as NSString).data(using: String.Encoding.utf8.rawValue)
            guard let encodedString = encodeString else {
                return
            }
            if let jsonText = try? JSON(data: encodedString) {
              //  print(jsonText)
                let sellersData =  jsonText["found"].array
                var mapMarkers : [CreditSellerMarker] = []
                mapMarkers = sellersData!.map{ CreditSellerMarker(sellerInfo: CreditSeller(json: $0)) }
                
//                if  let selfIndex = mapMarkers.index(where: {$0.sellerInfo.id == Defaults[.userId]}) {
//                mapMarkers.remove(at: selfIndex)
//                }
                var creditSellerMarkers : [CreditSellerMarker] = []
                for markers in mapMarkers {
                    if markers.sellerInfo.id != Defaults[.userId] {
                        creditSellerMarkers.append(markers)
                    }
                }
                showCreditSellerMarkersInMap(markers: creditSellerMarkers, isShop: false)
            }
            
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
       // print("web socket did receive data")
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
