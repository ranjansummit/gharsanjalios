//
//  NotificationManager.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/22/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class NotificationManager: BikeNotificationManagement {
    
    /// Fetches all notifications for usertype: Seller. This includes Vehicle request received, Credit Request received etc
    ///
    /// - Parameters:
    ///   - onSuccess: All notifications are bundled into BhatbhateUserNotification object and passed through closure
    ///   - onError: Error object is passed through closure
    func fetchAllSellerNotifications(onSuccess: @escaping (BhatbhateUserNotification) -> (), onError: @escaping (AppError) -> ()) {
        
        ApiManager.sendRequest(toApi: Api.Endpoint.notificationFromBuyer, onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                guard let _ = data["error"].bool else {
                    onError(CustomError.standard)
                    return
                }
                
                let notificationData = data["data"]
                let notificationModel = BhatbhateUserNotification(json: notificationData)
                
                onSuccess(notificationModel)
                
            default:
                
                if let message = data["message"].string {
                    onError(ApiError.invalidResponse(message: message))
                } else {
                    onError(CustomError.standard)
                }
            }
            
        }) { (error) in
            onError(error)
        }
    }
    
    func fetchAllNotifications(onSuccess: @escaping (BhatbhateUserNotification) -> (), onError: @escaping (AppError) -> ()) {
    ApiManager.sendRequest(toApi: .AllNotification, onSuccess: {status , data in
        //print(data)
        switch status {
        case 200:
            guard let _ = data["error"].bool else {
                onError(CustomError.standard)
                return
            }
            let notificationData = data["data"]
            let notificationModel = BhatbhateUserNotification(json: notificationData)
            
            onSuccess(notificationModel)
        default:
            break
        }
    }, onError: {error in
        
    })
    
    
    }
    
    /// Fetches all notifications for usertype: Buyer. This includes Vehicle info requests sent, Credit Request sent etc
    ///
    /// - Parameters:
    ///   - onSuccess: All notifications are bundled into BhatbhateUserNotification Object and passed through closure
    ///   - onError: Error object is passed through closure
    func fetchAllBuyerNotifications(onSuccess: @escaping (BhatbhateUserNotification) -> (), onError: @escaping (AppError) -> ()) {
        
        ApiManager.sendRequest(toApi: Api.Endpoint.AllNotification, onSuccess: { (statusCode, data) in
            
            switch statusCode {
                
            case 200:
                
                guard let _ = data["error"].bool else {
                    onError(CustomError.standard)
                    return
                }
                
                if  let myNotifCount = data["unread_notification"].int {
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
                
                let notificationData = data["data"]
                let notificationModel = BhatbhateUserNotification(json: notificationData)
                
                onSuccess(notificationModel)
                
            default:
                
                if let message = data["message"].string {
                    onError(ApiError.invalidResponse(message: message))
                } else {
                    onError(CustomError.standard)
                }
            }
            
        }) { (error) in
            onError(error)
        }
    }    
    
    /// Stores Or Updates the FCM push notification token in server
    ///
    /// - Parameter obtainedToken: token obtained from FCM Server
    class func updateFCMTokenIfNeeded(obtainedToken:String) {
        
        Log.add(info: "FCM Token Obtained: \(obtainedToken)")
        
        if shouldUpdateFCMToken(obtainedToken: obtainedToken) {
            
            ApiManager.sendRequest(toApi: Api.Endpoint.updateFCMToken(token: obtainedToken), onSuccess: { (statusCode, data) in
                
                if statusCode == 200 {
                    
                    Defaults[.fcmToken] = obtainedToken
                    Defaults.synchronize()
                }
                
                Log.add(info: "FCM Token Update Status: \(statusCode)")
                
            }, onError: { (error) in
                
                Log.error(info: "FCM Token Update Error: \(error.localizedDescription)")
            })
            
        }
    }
    
    /// Checks if the current obtained FCM token should be updated in server
    ///
    /// - Parameter obtainedToken: FCM Token
    /// - Returns: True is update is needed else false
    private class func shouldUpdateFCMToken(obtainedToken: String) -> Bool{
        
        guard Defaults[.isLoggedIn] else { return false }      // Only update if user is logged in
        
        guard let currentStoredToken = Defaults[.fcmToken] else { return true }
        
        return currentStoredToken != obtainedToken      // If not equal, should update it
    }
}
