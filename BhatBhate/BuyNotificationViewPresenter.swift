//
//  SellerNotificationPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/18/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
protocol BuyNotificationViewPresentation:BasePresentation, NetworkRequestPresentable {
    
    func displayDetailsOfBike(bike:Bike)
    func displaySellerInfo(vehicleId:Int)
    func displayMessage(message:String)
    
    func displayNotificationList()
    func displayError(error:AppError)
    
    func deleteNotification(at indexPath: IndexPath)
    func updateNotification(at indexPath: IndexPath)
}

class BuyNotificationViewPresenter {
    
    private weak var viewDelegate:BuyNotificationViewPresentation!
    private var notificationService: BikeNotificationManagement!
    
    var bikeNotifications = [BikeNotification]()
    var creditNotifications = [CreditNotification]()
    var allNotifications = [AllNotification]()
    var bikeSellNotifications = [BikeNotification]()
    
    var currentSection: NotificationSection = .allNotification // .bikeNotification
    var isSellerNotified:Bool = false
    init(viewDelegate:BuyNotificationViewPresentation,notificationService: BikeNotificationManagement) {
        
        self.viewDelegate = viewDelegate
        self.notificationService = notificationService
        
        self.viewDelegate.setupViews()
    }
    
    func fetchAllNotifications(){
        
        viewDelegate.showLoadingIndicator()
        notificationService.fetchAllNotifications(onSuccess: {notification in
            self.viewDelegate.hideLoadingIndicator()
            
        }, onError: {error in
            self.viewDelegate.hideLoadingIndicator()
            
        })
    }
    
    func fetchNotifications() {
        
        viewDelegate.showLoadingIndicator()
        
        notificationService.fetchAllBuyerNotifications(onSuccess: { [weak self] (notification) in
            guard let mySelf  = self else{
                return
            }
            mySelf.bikeNotifications = notification.bikeNotifications ?? []
            mySelf.creditNotifications = notification.creditNotifications ?? []
            mySelf.allNotifications = notification.allNotifications ?? []
            mySelf.bikeSellNotifications = notification.sellBikeNotifications ?? []
            
            mySelf.viewDelegate.hideLoadingIndicator() 
            mySelf.displayNotification(for: mySelf.currentSection)
            
        }) { [unowned self] (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
    func displayNotification(for section: NotificationSection) {
        if  Defaults[.myNotificationCount] != 0 {
        Defaults[.myNotificationCount] = 0
            resetNotificationCount()
        }
        // call api to reset the notification count in server
        // Update current Section
        self.currentSection = section
        
        switch section{
        case .allNotification:
            guard allNotifications.count > 0 else {
                self.viewDelegate.displayError(error: NotificationError.notificationEmpty)
                return
            }

        case .bikeNotification:
            
            guard bikeNotifications.count > 0 else {
                self.viewDelegate.displayError(error: NotificationError.bikeNotificationEmpty)
                return
            }
            
        case .bikeSellNotification:
            guard bikeSellNotifications.count > 0 else {
                self.viewDelegate.displayError(error: NotificationError.bikeNotificationEmpty)
                return
            }

        case .creditNotification:
            
            guard creditNotifications.count > 0 else {
                self.viewDelegate.displayError(error: NotificationError.creditNotificationEmpty)
                return
            }
        }
        
        self.viewDelegate.displayNotificationList()
    }
    
    func fetchSellerDetails(forVehicleId id:Int) {
        self.viewDelegate.displaySellerInfo(vehicleId: id)
    }
    
    func deleteCreditRequestNotification(atIndex index:Int, notificationId:Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeCreditNotificationStatus(response: 4, notificationId: notificationId, filter: "buyer"), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent  = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.creditNotifications.remove(at: index)
                    if let index = self.allNotifications.index(where: {$0.id == notificationId}){
                        self.allNotifications.remove(at: index)
                    }
                    self.viewDelegate.deleteNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
        
    }
    
    private func resetNotificationCount(){
        ApiManager.sendRequest(toApi: .ResetNotification, onSuccess: {
            status , data in
            if status == 200 {
                
            }
        }, onError: {appError in
            
        })
    }
    
    func notifySellerForInterestInPurchase(vehicleID:Int,notificationID:Int) {
        guard !isSellerNotified else {
            self.viewDelegate.displayMessage(message: "Seller has already been notified of your interest to purchase this bike")
            return
        }
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.notifySeller(vehicleId: vehicleID, notificatinID: notificationID), onSuccess: { [unowned self] (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if !isErrorPresent {
                    self.isSellerNotified = true
                    self.viewDelegate.displayMessage(message: "Seller will be notified of your interest to purchase this bike")
                } else {
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            case 404:
                
                let isErrorPresent = data["error"].bool ?? true
                if isErrorPresent {
                    self.isSellerNotified = true
                    self.viewDelegate.displayMessage(message: "Seller has already been notified of your interest to purchase this bike")
                } else {
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { [unowned self] (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
        
    }
    
    func deleteBikeNotificationRequest(atIndex index:Int, vehicleId: Int, notificationId: Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeBikeNotificationStaus(status: 4, vehicleID: vehicleId, filter: "buyer", notificationId: notificationId), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    if self.currentSection == .allNotification{
                     self.allNotifications.remove(at: index)
                        if let index = self.bikeNotifications.index(where: {$0.id == notificationId}){
                            self.bikeNotifications.remove(at: index)
                        }
                    }else{
                    self.bikeNotifications.remove(at: index)
                        if let index = self.allNotifications.index(where: {$0.id == notificationId}){
                            self.allNotifications.remove(at: index)
                        }
                    }
                    self.viewDelegate.deleteNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
}

extension BuyNotificationViewPresenter {
    
    func acceptBikeNotification(atIndex index:Int,withVehicleId id:Int, notificationId: Int) {
        
        // 1 Accept, 3 Decline
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeBikeNotificationStaus(status: 1, vehicleID: id, filter: "seller", notificationId: notificationId), onSuccess: {[weak self] (statusCode, data) in
            
            self?.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self?.viewDelegate.displayMessage(message: "Your information has been sent to buyer")
                    
                    self?.bikeSellNotifications[index].status = BikeNotificationStatus.accepted
                    if let index = self?.allNotifications.index(where: {$0.id == notificationId}){
                        self?.allNotifications[index].status = BikeNotificationStatus.accepted
                    }
                    self?.viewDelegate.updateNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    
                    self?.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self?.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
        
    }
    
    func rejectBikeNotification(atIndex index:Int,withVehicleId id:Int, notificationId: Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeBikeNotificationStaus(status: 3, vehicleID: id, filter: "seller", notificationId: notificationId), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.viewDelegate.displayMessage(message: "You have rejected buyer's request for your contact information")
                    if self.currentSection == .allNotification{
                        self.allNotifications.remove(at: index)
                        if let index = self.bikeSellNotifications.index(where: {$0.id == notificationId}) {
                        self.bikeSellNotifications.remove(at: index)
                        }
                    }else{
                    self.bikeSellNotifications.remove(at: index)
                        if let index = self.allNotifications.index(where: {$0.id == notificationId}){
                            self.allNotifications.remove(at: index)
                        }
                    }
                    self.viewDelegate.deleteNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
    func deleteBikeNotification(atIndex index:Int, vehicleId: Int, notificationId:Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeBikeNotificationStaus(status: 4, vehicleID: vehicleId, filter: "seller", notificationId: notificationId), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    if self.currentSection == .allNotification {
                        self.allNotifications.remove(at: index)
                        if let index = self.bikeSellNotifications.index(where: {$0.id == notificationId}){
                            self.bikeSellNotifications.remove(at: index)
                        }
                    }else if self.currentSection == .bikeNotification {
                        self.bikeNotifications.remove(at: index)
                    }else if self.currentSection == .bikeSellNotification {
                        self.bikeSellNotifications.remove(at: index)
                        if let index =  self.allNotifications.index(where: {$0.id == notificationId}){
                            self.allNotifications.remove(at: index)
                        }
                    }
                    self.viewDelegate.deleteNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    func deleteCreditNotification(atIndex index:Int, notificationId:Int,all:Bool,from:String) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeCreditNotificationStatus(response: 4, notificationId: notificationId, filter: from), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    if all {
                    self.allNotifications.remove(at: index)
                        if let index = self.creditNotifications.index(where: {$0.id == notificationId}){
                            self.creditNotifications.remove(at: index)
                        }
                    }else{
                    self.creditNotifications.remove(at: index)
                        if let index = self.allNotifications.index(where: {$0.id == notificationId}){
                            self.allNotifications.remove(at: index)
                        }
                    }
                    self.viewDelegate.deleteNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
        
    }
    
    func rejectCreditRequest(atIndex index:Int, notificationId:Int, fromAll:Bool) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeCreditNotificationStatus(response: 3, notificationId: notificationId, filter: "seller"), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent  = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.viewDelegate.displayMessage(message: "You have rejected buyer's request for credit")
                    if fromAll {
                        self.allNotifications.remove(at: index)
                        if let index = self.creditNotifications.index(where: {$0.id == notificationId}){
                            self.creditNotifications.remove(at: index)
                        }
                    }else{
                    self.creditNotifications.remove(at: index)
                        if let index = self.allNotifications.index(where: {$0.id == notificationId}){
                            self.allNotifications.remove(at: index)
                        }
                    }
                    self.viewDelegate.deleteNotification(at: IndexPath(row: index, section: 0))
                    
                } else {
                    
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: error)
        }
    }
    
    func updateCreditNotification(toStatus status: CreditNotificationStatus, at index:Int) {
        self.creditNotifications[index].status = status
        self.viewDelegate.updateNotification(at: IndexPath(row: index, section: 0))
    }
}
