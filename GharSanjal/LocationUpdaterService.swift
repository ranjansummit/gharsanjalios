//
//  LocationUpdaterService.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/12/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import SwiftyUserDefaults
/// This class is responsible for determining the real time location of current user & updating it to the server.
 var updated = false
class LocationUpdaterService:NSObject {
    
    public static let sharedInstance = LocationUpdaterService()
    
    private var coreLocationManager = CLLocationManager()
    public var onUpdateLocation : ((CLLocation)->())?
    override init() {
        
        coreLocationManager.requestAlwaysAuthorization()
        
        // core location initialization
    }
    
    // MARK:- Public Methods
    
    func getUserCurrentLocation(onSuccess:(CLLocation)->(),onError:(AppError)->()) {
        coreLocationManager.delegate = self
        self.coreLocationManager.requestWhenInUseAuthorization()
        self.coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            self.coreLocationManager.startUpdatingLocation()
        }
        
    }
    
    
    /*
     1. GetCurrentCoordinate
     2. Update current coordinate to server
     3.
     */
    
    
}


extension LocationUpdaterService: CLLocationManagerDelegate {
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        let _ = CLLocation(latitude: 21.4796719855459, longitude: 39.1840686276555)
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
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
    
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            coreLocationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        if updated {
            return
        }
        if let location = locations.last{
            updated = true
            self.onUpdateLocation!(location)
            self.coreLocationManager.stopUpdatingLocation()
            getPlacemark(forLocation: location){
                placeMark , text in
                guard let locality = placeMark?.locality else {
                    return
                }
                Defaults[.userLocality] = locality
                ApiManager.sendRequest(toApi: .updateUserLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, location: locality), onSuccess: {
                    status , response in
                    if status == 200 {
                        
                    }
                    
                }, onError: {
                    _ in
                })
            }
            
        }
    }
}
