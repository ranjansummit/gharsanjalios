//
//  SellerInfoPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/19/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit

protocol SellerInfoViewPresentation:BasePresentation, NetworkRequestPresentable {
    
    func setupViews()
    
    func displayError(error:AppError)
    func displaySellerInformation(name:String,address:String,email:String,phoneNumber:String,imageUrl:String,bikeName:String,bikePrice:String)
    func updateSellerLocation(latitude:Double,longitude:Double)
}

class SellerInfoPresenter {
    
    weak var viewDelegate:SellerInfoViewPresentation!
    
    init(viewDelegate:SellerInfoViewPresentation) {
        self.viewDelegate = viewDelegate
        self.viewDelegate.setupViews()
    }
    
    func fetchSellerInfo(ofVehicleId id:Int) {
        
        self.viewDelegate.showLoadingIndicator()
        ApiManager.sendRequest(toApi: Api.Endpoint.sellerInformation(vehicleId: id), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
            case 200:
                
                self.viewDelegate.hideLoadingIndicator()
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    let sellerName = data["data"]["seller_name"].string ?? ""
                    let sellerImage = data["data"]["seller_image"].string ?? ""
                    let email = data["data"]["email"].string ?? "Not Available"
                    let mobile = data["data"]["mobile"].string ?? "Not Available"
                    let location = data["data"]["location"].string ?? ""
                    let latitude = data["data"]["latitude"].double ?? 0.0
                    let longitude = data["data"]["longitude"].double ?? 0.0
                    let bikePrice = data["data"]["price"].double ?? 0.0
                    let bikeName = data["data"]["bike_name"].string ?? "--"
                    let pp = "Rs. \(bikePrice.formatCurrency())"
                    self.viewDelegate.displaySellerInformation(name: sellerName, address: location, email: email, phoneNumber: mobile, imageUrl: sellerImage, bikeName: bikeName, bikePrice: pp)
                    self.viewDelegate.updateSellerLocation(latitude: latitude, longitude: longitude)
                    
                } else {
                    
                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: CustomError.with(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
}
