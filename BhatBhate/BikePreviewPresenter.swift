//
//  BikePreviewPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/17/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults
protocol BikePreviewViewPresentation:class, NetworkRequestPresentable {
    
    func setupViews(forState state:BikePreviewState)
    func updateBikeInfo(bike:Bike)
    func BikeUploadSucceeded(isDraft:Bool)
    func displaySuccessIfNotifiedToSeller(message:String)
    func updateBadge(remainingCredit:Int)
    func displayError(error:AppError)
    func displayMessage(message:String)
    func updateBike(wished:Bool)
}

class BikePreviewPresenter {
    
    private weak var viewDelegate:BikePreviewViewPresentation!
    private var presentationState:BikePreviewState!
    private var bikeModel: Bike!
    private var wishlistService: WishlistDataManagement!
    private var isSellerNotified:Bool = false
    private var isDraft = false
    init(viewDelegate:BikePreviewViewPresentation,state:BikePreviewState,bikeModel:Bike) {
        self.viewDelegate = viewDelegate
        self.presentationState = state
        self.bikeModel = bikeModel
        self.viewDelegate.setupViews(forState: state)
        wishlistService = WishlistManager()
    }
    
    func displayBikePreview() {
        self.viewDelegate.updateBikeInfo(bike: bikeModel)
    }
    
    func notifySellerForInterestInPurchase() {
        guard !isSellerNotified else {
            
            self.viewDelegate.displaySuccessIfNotifiedToSeller(message: "Seller has already been notified of your interest to purchase this bike")
            return
        }
        
        self.viewDelegate.showLoadingIndicator()
        ApiManager.sendRequest(toApi: Api.Endpoint.notifySeller(vehicleId: bikeModel.id!, notificatinID: nil), onSuccess: { [unowned self] (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if !isErrorPresent {
                    Defaults[.reloadBuyListing] = true
                    self.isSellerNotified = true
                    self.viewDelegate.displaySuccessIfNotifiedToSeller(message: "Seller will be notified of your interest to purchase this bike")
                } else {
                    self.viewDelegate.displayError(error: CustomError.standard)
                }
                
            case 404:
                
                let isErrorPresent = data["error"].bool ?? true
                if isErrorPresent {
                    self.isSellerNotified = true
                    self.viewDelegate.displaySuccessIfNotifiedToSeller(message: "Seller has already been notified of your interest to purchase this bike")
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
    
    
    func addBikeToWishlist( bikeID:Int?) {
        
        if let bikeId = bikeID {
            
            self.viewDelegate.showLoadingIndicator()
            wishlistService.addBikeToWishlist(bikeId: bikeId, onSuccess: {
                Defaults[.myWishlistCount] += 1
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.updateBike(wished: true)
                self.viewDelegate.displayMessage(message: "Added to wishlist")
                
            }, onError: { (error) in
                
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: error)
            })
        }
    }
    
    func removeBikeFromWishlist( bikeID:Int?) {
        
        if let bikeId = bikeID {
            
            self.viewDelegate.showLoadingIndicator()
            wishlistService.removeBikeFromWishlist(bikeId: bikeId, onSuccess: {
                Defaults[.myWishlistCount] -= 1
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.updateBike(wished: false)
                self.viewDelegate.displayMessage(message: "Removed from wishlist")
                
            }, onError: { (error) in
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: error)
            })
        }
    }
    
    func performActionOnRightButtonTap() {
        print(GlobalVar.sharedInstance.answer1)
        GlobalVar.sharedInstance.answer1["publish"] = "1"
        print(GlobalVar.sharedInstance.answer1)
        isDraft = false
        saveBike()
    }
    func performSaveDraftAction(){
        print(GlobalVar.sharedInstance.answer1)
        GlobalVar.sharedInstance.answer1["publish"] = "0"
        isDraft = true
        print(GlobalVar.sharedInstance.answer1)
        saveBike()
    }
    
    private func saveBike(){
        LoadingIndicatorView.show()
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key,value) in GlobalVar.sharedInstance.answer {
                switch key {
                case "front_side_image":
                    multipartFormData.append(value as! Data, withName: key, fileName: key, mimeType: "image/jpeg")
                case "left_side_image":
                    multipartFormData.append(value as! Data, withName: key, fileName: key, mimeType: "image/jpeg")
                case "right_side_image":
                    multipartFormData.append(value as! Data, withName: key, fileName: key, mimeType: "image/jpeg")
                case "back_side_image":
                    multipartFormData.append(value as! Data, withName: key, fileName: key, mimeType: "image/jpeg")
                default:
                    break
                }
                
            }
            
            let parameters = GlobalVar.sharedInstance.answer1
            for (key,value) in parameters {
                let val = value
                multipartFormData.append(val.data(using: .utf8)!, withName: key)
            }
            
        }, to: Api.Endpoint.saveBike.url, method: Api.Endpoint.saveBike.method, headers: Api.Endpoint.saveBike.headers, encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
                
            case .success(let uploadRequest,_,_):
                
                uploadRequest.response(completionHandler: { (networkResponse) in
                    
                    self.viewDelegate.hideLoadingIndicator()
                    
                    // If any unforseen error
                    if let error = networkResponse.error {
                        print(error.localizedDescription)
                        //self.viewDelegate.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
                        return
                    }
                    
                    guard let data = networkResponse.data else {
                       // print("unknown error")
                        //self.viewDelegate.displayError(error: UnknownError.standard)
                        return
                    }
                    
                    let response = JSON(data)
                    print(response)
                    if let isErrorPresent = response["error"].bool, isErrorPresent == false {
                        if let remainingCredit = response["data"]["remaining_credit"].int{
                            Defaults[.userCreditCount] = remainingCredit
                            NotificationCenter.default.post(name:.updateBadge,object:nil)
                        }
                      //  print("success fully uploaded the bike")
                        Defaults[.reloadSellLsting] = true
                        GlobalVar.sharedInstance.answer = [:]
                        GlobalVar.sharedInstance.answer1 = [:]
                        self.viewDelegate.BikeUploadSucceeded(isDraft: self.isDraft)
                        return
                        
                    } else {
                        /// filter error code
                        if let errorCode = response["error_code"].int , errorCode == 105 {
                            let message = response["message"].string ?? "Duplicate entry"
                            self.viewDelegate.displayError(error: BikeListError.duplicateEntry(msg: message))
                            return
                        }
                        // let message = response["message"].string ?? ""
                        self.viewDelegate.displayError(error: BikeListError.noCreditError)
                    }
                })
                
            case .failure(let error):
                Log.error(info: error)
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
            }
            
        })
    }
    
}
