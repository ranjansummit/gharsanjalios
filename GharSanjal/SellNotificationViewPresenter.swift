//
//  SellNotificationViewPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/10/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import Foundation

protocol SellNotificationViewPresentation: BasePresentation, NetworkRequestPresentable {
    
    func displayNotificationList()
    func displayError(error:AppError)
    func displayMessage(message:String)
    
    func updateNotification(at indexPath:IndexPath)
    func deleteNotification(at indexPath:IndexPath)
}

class SellNotificationViewPresenter {
    
    private weak var viewDelegate: SellNotificationViewPresentation!
    private var notificationService: BikeNotificationManagement!
    
    var bikeNotifications = [BikeNotification]()
    var creditNotifications = [CreditNotification]()
    
    var currentSection: NotificationSection = .bikeNotification
    
    init(viewDelegate: SellNotificationViewPresentation, notificationService: BikeNotificationManagement) {
        
        self.viewDelegate = viewDelegate
        self.notificationService = notificationService
        
        self.viewDelegate.setupViews()
    }
    
    func fetchNotifications() {
        
        viewDelegate.showLoadingIndicator()
        
        notificationService.fetchAllSellerNotifications(onSuccess: { [weak self] (notification) in
            
            self?.bikeNotifications = notification.bikeNotifications ?? []
            self?.creditNotifications = notification.creditNotifications ?? []
            
            self?.viewDelegate.hideLoadingIndicator()
            self?.displayNotification(for: (self?.currentSection)!)
            
        }) { [unowned self] (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayNotificationList()
        }
    }
    
    func displayNotification(for section:NotificationSection) {
        
        self.currentSection = section
        
        switch section {
        case .bikeNotification:
            
            guard bikeNotifications.count > 0 else {
                self.viewDelegate.displayError(error: NotificationError.bikeNotificationEmpty)
                return
            }
            
        case .creditNotification:
            guard creditNotifications.count > 0 else {
                self.viewDelegate.displayError(error: NotificationError.creditNotificationEmpty)
                return
            }
        case .allNotification:
            break
        case .bikeSellNotification:
            break
        }
        
        self.viewDelegate.displayNotificationList()
    }
    
    func acceptBikeNotification(atIndex index:Int,withVehicleId id:Int, notificationId: Int) {
        
        // 1 Accept, 3 Decline
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeBikeNotificationStaus(status: 1, vehicleID: id, filter: "seller", notificationId: notificationId), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.viewDelegate.displayMessage(message: "Your information has been sent to buyer")
                    
                    self.bikeNotifications[index].status = BikeNotificationStatus.accepted
                    self.viewDelegate.updateNotification(at: IndexPath(row: index, section: 0))
                    
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
    
    func rejectBikeNotification(atIndex index:Int,withVehicleId id:Int, notificationId: Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeBikeNotificationStaus(status: 3, vehicleID: id, filter: "seller", notificationId: notificationId), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.viewDelegate.displayMessage(message: "You have rejected buyer's request for your contact information")
                    
                    self.bikeNotifications.remove(at: index)
                    
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
    
    func rejectCreditRequest(atIndex index:Int, notificationId:Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeCreditNotificationStatus(response: 3, notificationId: notificationId, filter: "seller"), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent  = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.viewDelegate.displayMessage(message: "You have rejected buyer's request for credit")
                    
                    self.creditNotifications.remove(at: index)
                    
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
                    
                    self.bikeNotifications.remove(at: index)
                    
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
    
    func deleteCreditNotification(atIndex index:Int, notificationId:Int) {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.changeCreditNotificationStatus(response: 4, notificationId: notificationId, filter: "seller"), onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    self.creditNotifications.remove(at: index)
                    
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
