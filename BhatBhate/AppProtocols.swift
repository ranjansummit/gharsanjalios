//
//  AppProtocols.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/20/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit

protocol BasePresentation: class {
    
    func setupViews()
}

protocol NetworkRequestPresentable {
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

extension NetworkRequestPresentable {
    
    func showLoadingIndicator() {
        LoadingIndicatorView.show()
    }
    
    func hideLoadingIndicator() {
        LoadingIndicatorView.hide()
    }
}

protocol PushNotificationBadgePresentable {
    
    var notificationBadge: UILabel? { get set }
    
    func updateNotificationBadge(count: Int)
}

extension PushNotificationBadgePresentable {
    
    func updateNotificationBadge(count: Int) {
        
        if count > 0 {
            notificationBadge?.isHidden = false
            notificationBadge?.text = "\(count)"
        } else {
            notificationBadge?.text = ""
            notificationBadge?.isHidden = true
        }
    }
}

protocol WishlistDataManagement {
    
    func fetchAllBikeInWishlist(pageOffset:Int, limitPerPage:Int, onSuccess: @escaping ([Bike])->(),onError: @escaping (AppError)->())
    func addBikeToWishlist(bikeId:Int,onSuccess: @escaping ()->(),onError:@escaping (AppError)->())
    func removeBikeFromWishlist(bikeId:Int,onSuccess: @escaping ()->(), onError: @escaping (AppError)->())
}

protocol BikeDataManagement {
    
    func fetchBikeList(withBrand brand:String,model:String,price:String,condition:Int,pageOffset:Int,limitPerPage:Int,isOwn:Bool, onSuccess: @escaping ([Bike],Int) -> (),onError: @escaping (AppError) -> ())
    func fetchBikeList(pageOffset:Int,limitPerPage:Int,onSuccess: @escaping ([Bike],Int)->(),onError: @escaping (AppError)-> ())
    func fetchBikeDetails(withId id:Int,onSuccess: @escaping (Bike)->(), onError: @escaping (AppError) -> ())
}

protocol BikeNotificationManagement {
    
    func fetchAllBuyerNotifications(onSuccess: @escaping (BhatbhateUserNotification)->(), onError: @escaping (AppError)->())
    func fetchAllSellerNotifications(onSuccess: @escaping (BhatbhateUserNotification)->(), onError: @escaping (AppError)->())
    func fetchAllNotifications(onSuccess: @escaping (BhatbhateUserNotification)->(), onError: @escaping (AppError)->())
    
}
