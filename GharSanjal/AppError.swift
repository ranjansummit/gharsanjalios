//
//  AppError.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/23/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation

protocol AppError: Error {
    var localizedDescription:String {get}
}

enum ApiError: AppError {
    
    case invalidResponse(message:String)
    
    var localizedDescription: String {
        
        switch self {
        case .invalidResponse(let message):
            return message
        }
    }
}

enum LocationError: AppError {
    
    case cannotDetermineLocation
    case notAuthorized
    
    var localizedDescription: String {
        
        switch self {
        case .cannotDetermineLocation:
            return "Sorry! We cannot determine your location at this time. Try again later."
        case .notAuthorized:
            return "Please enable location service for Bhatbhate app from your device settings."
        }
    }
}

enum ProfileError: AppError {
    
    case invalidName
    case invalidPhoneNumber
    case invalidPassword
    case passwordMismatch
    case uploadError
    
    var localizedDescription: String {
        switch self {
        case .invalidName:
            return "Name invalid"
        case .invalidPhoneNumber:
            return "Phone number invalid"
        case .invalidPassword:
            return "Password invalid"
        case .passwordMismatch:
            return "New password & Confirm password should be same"
        case .uploadError:
            return "Your profile cannot be updated at this time. Try again later"
        }
    }
}

enum BikeListError: AppError {
    
    case emptyWishlist
    case emptyBuyList
    case emptySellList
    case noMoreBikeForFilter
    case notFoundInSearch
    case noCreditError
    case duplicateEntry(msg:String)
    var localizedDescription: String {
        switch self {
        case .emptyWishlist:
            return "You don't have any bikes in your wishlist."
        case .emptyBuyList:
            return "There aren't any bikes listed for sell. Try again later. \nPull to refresh bike listings."
        case .emptySellList:
            return "You don't have any bike to sell."
        case .noMoreBikeForFilter:
            return "You have reached the end of the list."
        case .notFoundInSearch:
            return "Bike not found matching the search criteria."
        case .noCreditError:
            return "You don’t have any credit to sell this bike - You can save as a draft. Please click Credits below to buy a credit to publish and sell your bike.   "
        case .duplicateEntry(let msg):
            return msg
        }
    }
}

enum NotificationError: AppError {
    
    case bikeNotificationEmpty
    case creditNotificationEmpty
    
    case notificationEmpty
    
    var localizedDescription: String {
        switch self {
        case .notificationEmpty:
            return "You don't have any notifications."
        case .bikeNotificationEmpty:
            return "You don't have any notifications related to bike."
        case .creditNotificationEmpty:
            return "You don't have any notifications related to credits."
        }
    }
}

enum CustomError: AppError {
    
    case with(message:String)
    case standard
    
    var localizedDescription: String {
        switch self {
        case .with(let message):
            return message
        default:
            return "Sorry! We encountered an error. Try again later."
        }
    }
}
