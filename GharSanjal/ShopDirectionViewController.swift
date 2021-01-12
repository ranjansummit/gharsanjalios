//
//  ShopDirectionViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/2/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import SwiftyUserDefaults
class ShopDirectionViewController: RootViewController {

    private let GOOGLE_DIRECTION_API_KEY = "AIzaSyDD5Xj754UpMHMo1-woHlTpC4r4cAsD0HI"
    
    private var sourceMarker:GMSMarker!
    private var destinationMarker:GMSMarker!
    private var googleMapView: GMSMapView!
    
    @IBAction func exportToGoogleMap(_ sender: Any) {
    }
    public var sourcePosition: CLLocationCoordinate2D!
    public var destinationPosition: CLLocationCoordinate2D!
    public var destinationName:String?
    public var destinationMobile:String?
    public var isFromShopCredit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        showDirection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    func setupMapView() {
    
      //  self.title = "Direction"
        
        googleMapView = GMSMapView.map(withFrame: self.view.frame, camera: GMSCameraPosition.camera(withTarget: sourcePosition, zoom: 15))
        self.view = googleMapView
        self.googleMapView.delegate = self
        sourceMarker = GMSMarker()
        sourceMarker.position = self.sourcePosition
        sourceMarker.title = "Me"
        sourceMarker.icon = GMSMarker.markerImage(with: .red)
        sourceMarker.appearAnimation = .pop
        sourceMarker.map = self.googleMapView
        
       
        destinationMarker = GMSMarker()
        destinationMarker.position = self.destinationPosition
       
        destinationMarker.title = "\(isFromShopCredit ? "Shop:":"Buyer:") \(destinationName!) \n Mobile: \(destinationMobile!)"
        
        destinationMarker.icon = GMSMarker.markerImage(with: .black)
        destinationMarker.appearAnimation = .pop
        destinationMarker.map = self.googleMapView

    }
    
    func showDirection() {
        
        let routeURL = URL(string: "https://maps.googleapis.com/maps/api/directions/json")!
        
        var urlComponents = URLComponents(url: routeURL, resolvingAgainstBaseURL: false)
        let query1 = URLQueryItem(name: "origin", value:"\(sourcePosition.latitude),\(sourcePosition.longitude)")
        let query2 = URLQueryItem(name: "destination", value:"\(destinationPosition.latitude),\(destinationPosition.longitude)")
        let query3 = URLQueryItem(name: "key", value: GOOGLE_DIRECTION_API_KEY)
        
        urlComponents?.queryItems = [query1,query2,query3]
        
        let queryUrl = urlComponents!.url!
        
        URLSession.shared.dataTask(with: queryUrl) { (data, response, error) in
            
            if let error = error {
                Log.error(info: "Error while fetching routes: \(error)")
                
                DispatchQueue.main.async {
                    self.showAlert(title: "", message: "Error fetching directions")
                }
                
                return
            }
            
            guard let data = data else {
                Log.error(info: "Routes are not available")
                
                DispatchQueue.main.async {
                    self.showAlert(title: "", message: "Cannot show route to seller. Try again later")
                }
                
                return
            }
            
            let responseData = try? JSON(data: data)
            if let status = responseData!["status"].string, status == "OK" {
                
                let routes = responseData!["routes"].array!
                
                DispatchQueue.main.async {
                    
                    self.googleMapView.clear()
                    self.sourceMarker.map = self.googleMapView
                    self.destinationMarker.map = self.googleMapView
                    
                    for route in routes {
                        
                        let routeOverviewPolyline = route["overview_polyline"].dictionaryObject!
                        let points = routeOverviewPolyline["points"] as! String
                        let path = GMSPath.init(fromEncodedPath: points)
                        
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 4
                        polyline.strokeColor = AppTheme.Color.primaryBlue
                        let bounds = GMSCoordinateBounds(path: path!)
                        self.googleMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                        
                        polyline.map = self.googleMapView
                    }
                }
            }
            
        }.resume()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ShopDirectionViewController:GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        print(marker)
        if marker.title == "Me"{
            return nil
        }
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 70))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 25))
        lbl1.text = "\(isFromShopCredit ? "Shop:":"Buyer:") \(destinationName!)"
        view.addSubview(lbl1)
        
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl2.text = "Mobile: \(destinationMobile!)"
        lbl2.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.addSubview(lbl2)
        
        return view
//        print(marker)
//        let infoView = MarkerInfoView()
//        infoView.set(mobile: "mobile")
//        infoView.set(name: "name")
//        return infoView
    }
}
