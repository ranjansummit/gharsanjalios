//
//  WishlistManager.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/22/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
class WishlistManager: WishlistDataManagement {
    
    func addBikeToWishlist(bikeId: Int, onSuccess: @escaping () -> (), onError: @escaping (AppError) -> ()) {
        
        ApiManager.sendRequest(toApi: Api.Endpoint.addToWishlist(bikeId: bikeId), onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if isErrorPresent {
                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    onError(ApiError.invalidResponse(message: message))
                } else {
                    onSuccess()
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                onError(ApiError.invalidResponse(message: message))
                
            }
            
        }) { (error) in
            
            onError(error)
        }
    }
    
    func removeBikeFromWishlist(bikeId: Int, onSuccess: @escaping () -> (), onError: @escaping (AppError) -> ()) {
        
        ApiManager.sendRequest(toApi: .removeFromWishlist(bikeId: bikeId), onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if isErrorPresent {
                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    onError(ApiError.invalidResponse(message: message))
                } else {
                    onSuccess()
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                onError(ApiError.invalidResponse(message: message))
                return
            }
            
        }) { (error) in
            
            onError(error)
        }
    }
    
    func fetchAllBikeInWishlist(pageOffset: Int, limitPerPage: Int, onSuccess: @escaping ([Bike]) -> (), onError: @escaping (AppError) -> ()) {
        
        ApiManager.sendRequest(toApi: Api.Endpoint.getVehicles(filter: "wishlist", offset: pageOffset, limit: limitPerPage), onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if isErrorPresent {
                    // There should have been message, but in this case there is no message sent from api
                    onError(CustomError.standard)
                } else {
                    
                    if let myNotifCount = data["unread_notification"].int {
                    Defaults[.myNotificationCount] = myNotifCount
                    }
                    if let bikeCount = data["vehicles_count"].int {
                    Defaults[.bikeCount] = bikeCount
                    }
                    if let wishlistCount = data["wishlist_count"].int {
                    Defaults[.myWishlistCount] = wishlistCount
                    }
                    if let promotionMode = data["promotion_mode"].int {
                    Defaults[.promotionMode] = promotionMode == 1
                    }
                    let normalCredit = data["normal_credit"].int ?? 500
                    Defaults[.normalCredit] = normalCredit
                    
                    let discountedCredit = data["discounted_credit"].int ?? 400
                    Defaults[.discountedCredit] = discountedCredit
                    
                    
                    let bikeData = data["data"].arrayValue
                    let bikeList:[Bike] = bikeData.map{ Bike(json: $0) }
                    
                  //  if bikeList.count > 0 {
                        onSuccess(bikeList)
//                    } else {
//                        onError(BikeListError.emptyWishlist)
//                    }
                }
                
            default:
                onError(CustomError.standard)
            }
            
        }) { (error) in
            
            Log.error(info: error.localizedDescription)
            onError(error)
        }
    }
    
}
