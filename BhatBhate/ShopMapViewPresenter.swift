//
//  ShopMapViewPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 12/21/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps

protocol ShopMapViewPresentation: BasePresentation, NetworkRequestPresentable {
    
    func showSellerInfo(name:String,address:String,email:String,phoneNumber:String,imageUrl:String)
    func showMapView(with location:CLLocation)
    func showCreditSellerMarkersInMap(markers:[CreditSellerMarker],isShop:Bool)
    
    func showError(error:AppError)
    func showMessage(message:String)
}

class ShopMapViewPresenter {
    
    private weak var viewDelegate: ShopMapViewPresentation!
    
    private var mapMarkers = [CreditSellerMarker]()
    private var creditSellers = [CreditSeller]()
    private var userLocation: CLLocation!
    
    init(controller: ShopMapViewPresentation) {
        self.viewDelegate = controller
        self.viewDelegate.setupViews()
    }
    
    func setupMap(forLocation location: CLLocation) {
        
        self.userLocation = location
        //self.viewDelegate.showMapView(with: location)
        self.fetchCreditSellerList(aroundLocation: location)
    }
    
    func getUserCurrentLocation() -> CLLocationCoordinate2D {
        return userLocation.coordinate
    }
    
    
    
    func fetchCreditSellerList(aroundLocation location:CLLocation) {
        
        ApiManager.sendRequest(toApi: Api.Endpoint.shopList(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), onSuccess: { [weak self] (statusCode, data) in
            
            self?.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                if let sellersData = data["data"].array {
                    
                    self?.mapMarkers = sellersData.map{ CreditSellerMarker(sellerInfo: CreditSeller(json: $0)) }

                    //self.creditSellers = sellersData.map{ CreditSeller(json: $0) }
                    self?.viewDelegate.showCreditSellerMarkersInMap(markers: (self?.mapMarkers)!,isShop:true)
                    
                } else {
                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    self?.viewDelegate.showError(error: ApiError.invalidResponse(message: message))
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self?.viewDelegate.showError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.showError(error: error)
        }
    }
    
    func requestSellerForCredit(amount:Int,sellerId:Int) {
        
        self.viewDelegate.showLoadingIndicator()
        ApiManager.sendRequest(toApi: Api.Endpoint.creditRequest(sellerId: sellerId, credit: amount), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
            case 200:
                let errorStatus = data["error"].bool ?? true
                if !errorStatus {
                    self.viewDelegate.showMessage(message: "Seller has been notified of your credit request.If it is accepted, he/she will be coming to you.")
                } else {
                    self.viewDelegate.showError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? ""
                self.viewDelegate.showError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.showError(error: error)
        }
    }
    
    
}



