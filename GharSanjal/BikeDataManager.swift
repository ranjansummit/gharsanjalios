//
//  BikeDataManager.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/22/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class BikeDataManager: BikeDataManagement {
    
    /**
     This returns bike list for buy landing page
     ## Important Notes ##
     1. It uses page offset and limit per page
     
     */
    
    func fetchBikeList(pageOffset:Int,limitPerPage:Int,onSuccess: @escaping ([Bike],Int) -> (), onError: @escaping (AppError) -> ()) {
        var endPoint: Api.Endpoint!
        if let _ = Defaults[.accessToken]{
            endPoint = Api.Endpoint.getVehicles(filter: "buy", offset: pageOffset, limit: limitPerPage)
        }else{
            endPoint = Api.Endpoint.preLoginVehicles(offset: pageOffset, limit: limitPerPage)
        }
        ApiManager.sendRequest(toApi: endPoint, onSuccess: { (statusCode, data) in
            
            switch statusCode{
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if isErrorPresent {
                    // There should have been message, but in this case there is no message sent from api
                    onError(CustomError.standard)
                    
                } else {
                    
                    var bikeList = [Bike]()
                    
                    // Setting up buy count
                    if let bikeCount = data["vehicles_count"].int {
                    Defaults[.bikeCount] = bikeCount
                    }
                    let wishlistCount = data["wishlist_count"].int ?? 0
                    Defaults[.myWishlistCount] = wishlistCount
                    
                    if let preview = data["onreview"].int {
                        Defaults[.preview] = false//preview == 1
                    }
                    
                    
                    if let promotionMode = data["promotion_mode"].int {
                    Defaults[.promotionMode] = promotionMode == 1
                    }
                    let normalCredit = data["normal_credit"].int ?? 500
                    Defaults[.normalCredit] = normalCredit
                    
                    let discountedCredit = data["discounted_credit"].int ?? 400
                    Defaults[.discountedCredit] = discountedCredit
                    
                    if let notificationCount = data["unread_notification"].int {
                    Defaults[.myNotificationCount] = notificationCount
                    }
                    
                    let bikeData = data["data"].arrayValue
                    
                    for data in bikeData {
                        let bike = Bike(json: data)
                        bikeList.append(bike)
                    }
                    
                    if bikeList.count > 0 {
                        onSuccess(bikeList,wishlistCount)
                    } else {
                        onError(BikeListError.emptyBuyList)
                    }
                }
                
            default:
                onError(CustomError.standard)
                break
            }
            
        }) { (error) in
            
            Log.error(info: error.localizedDescription)
            onError(error)
        }
    }
    
    /**
     This returns bike list for search/filter conditions
     ## Important Notes ##
     1. It uses parameters:  brand, model, price, condition, offset, limit,(own for logged in)
     
     */
    
    func fetchBikeList(withBrand brand: String, model: String, price: String,condition:Int,pageOffset:Int,limitPerPage:Int,isOwn:Bool, onSuccess: @escaping ([Bike],Int) -> (), onError: @escaping (AppError) -> ()) {
        var endPoint: Api.Endpoint!
        if let _ = Defaults[.accessToken]{
            endPoint = Api.Endpoint.searchBike(brand: brand, model: model, price: price, condition: condition,offset: pageOffset,limit:limitPerPage, isOwn: isOwn)
        }else{
            endPoint = Api.Endpoint.preLoginSearchBike(brand: brand, model: model, price: price, condition: condition, offset: pageOffset, limit: limitPerPage)
        }
        ApiManager.sendRequest(toApi: endPoint, onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if isErrorPresent {
                    // There should have been message, but in this case there is no message sent from api
                    onError(CustomError.standard)
                } else {
                    
                    var bikeList = [Bike]()
                    let bikeData = data["data"].arrayValue
                    let wishlistCount = data["wishlist_count"].int ?? 0
                   // Defaults[.myWishlistCount] = wishlistCount
                    for data in bikeData {
                        let bike = Bike(json: data)
                        bikeList.append(bike)
                    }
                    
                    if bikeList.count > 0 {
                        onSuccess(bikeList,wishlistCount)
                    } else {
                        if pageOffset > 0 {
                         onError(BikeListError.noMoreBikeForFilter)  // search result is nil
                        }else{
                        onError(BikeListError.notFoundInSearch) // search result is at end of search results
                        }
                    }
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                onError(ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            onError(error)
        }
    }
    
    /**
     This returns bike detains for bike id
     ## Important Notes ##
     1. It uses parameters as bikeid
     
     */
    func fetchBikeDetails(withId id: Int, onSuccess: @escaping (Bike) -> (), onError: @escaping (AppError) -> ()) {
        
        ApiManager.sendRequest(toApi: Api.Endpoint.vehicleDetails(id: id), onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                if let isErrorPresent = data["error"].bool, !isErrorPresent {
                    
                    let bikeData = data["data"]
                    let bike = Bike(json: bikeData)
                    onSuccess(bike)
                    
                } else {
                    onError(CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                onError(ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            onError(error)
        }
    }
    
}
