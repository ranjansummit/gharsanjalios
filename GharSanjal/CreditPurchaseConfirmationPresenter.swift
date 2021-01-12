//
//  CreditPurchaseConfirmationPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/17/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
enum PurchaseType:String {
    case esewa = "esewa"
    case qr = "qrcode"
    case alphaCode = "alphaCode"
}

protocol CreditPurchaseConfirmationViewPresentation: BasePresentation, NetworkRequestPresentable {
    
    func setupPurchaseInformation(sellerName:String,sellerImage:String,sellerAddress:String,quantity:String,rate:String,totalAmount:String)
    
    func displayError(error:AppError)
    func displayMessage(message: String)
    func displayPurchaseConfirmation(creditQuantity: Int, rate: Double, amount: Double)
}

class CreditPurchaseConfirmationPresenter {
    
    fileprivate var viewDelegate: CreditPurchaseConfirmationViewPresentation!
    
    fileprivate var currentPurchaseType: PurchaseType = .qr
    fileprivate var scannedTransactionCode: String?
    fileprivate var transactionCodeId: Int?
    
    fileprivate var creditQuantity: Int = 0
    fileprivate var creditRate: Double = 0.0
    fileprivate var creditAmount: Double = 0.0
    
    init(controller: CreditPurchaseConfirmationViewPresentation, purchaseType: PurchaseType) {
        self.viewDelegate = controller
        self.currentPurchaseType = purchaseType
        self.viewDelegate.setupViews()
       
        
    }
    
    func processAlphaCodeValue(value:[String:JSON]){
        let sellerName = value["seller_name"]?.string ?? ""
        let sellerAddress = value["location"]?.string ?? ""
        let sellerImageURL = value["seller_image"]?.string ?? ""
        creditQuantity = value["credit"]?.int ?? 0
        creditRate = Double(value["rate"]?.int ?? 0)
        creditAmount = Double(value["amount"]?.int ?? 0)
        scannedTransactionCode = value["qr_code"]?.string
        transactionCodeId = value["id"]?.int
        self.viewDelegate.setupPurchaseInformation(sellerName: sellerName, sellerImage: sellerImageURL, sellerAddress: sellerAddress, quantity: "\(Int(creditQuantity))", rate: "\(Int(creditRate))", totalAmount: "\(Int(creditAmount))")
    }
    
    
    
    func processScannedValue(value: String?) {
        
        let data = value!.data(using: .utf8)!
        
        let scannedValue = JSON(data)
        
        Log.add(info: scannedValue)
        
        let sellerName: String = scannedValue[CreditQRCode.Key.sellerName].string ?? ""
        let sellerAddress: String = scannedValue[CreditQRCode.Key.location].string ?? ""
        let sellerImageUrl: String = scannedValue[CreditQRCode.Key.sellerImageUrl].string ?? ""
        creditQuantity = scannedValue[CreditQRCode.Key.creditQuantity].int ?? 0
        creditRate = scannedValue[CreditQRCode.Key.rate].double ?? 0.0
        creditAmount = scannedValue[CreditQRCode.Key.totalAmount].double ?? 0.0
        scannedTransactionCode = scannedValue[CreditQRCode.Key.code].string
        transactionCodeId = scannedValue[CreditQRCode.Key.codeId].int
        
        self.viewDelegate.setupPurchaseInformation(sellerName: sellerName, sellerImage: sellerImageUrl, sellerAddress: sellerAddress, quantity: "\(Int(creditQuantity))", rate: "\(Int(creditRate))", totalAmount: "\(Int(creditAmount))")
    }
    
    func purchaseAlphaCodeBasedCredit() {
        purchaseQRBasedCredit()
    }
    
    func purchaseQRBasedCredit() {
        
        if let transactionCode = scannedTransactionCode, let transactionId = transactionCodeId {
         
            self.viewDelegate.showLoadingIndicator()
            
            ApiManager.sendRequest(toApi: Api.Endpoint.purchaseCredit(qrCode: transactionCode, id: transactionId), onSuccess: { (statusCode, data) in
                
                self.viewDelegate.hideLoadingIndicator()
                
                switch statusCode {
                    
                case 200:
                    
                    let isErrorPresent = data["error"].bool ?? true
                    
                    if !isErrorPresent {
                        
                        self.viewDelegate.displayPurchaseConfirmation(creditQuantity: self.creditQuantity, rate: self.creditRate, amount: self.creditAmount)
                    }
                    
                default:

                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
                    
                }
                
                
            }, onError: { (error) in
                
                self.viewDelegate.hideLoadingIndicator()
                self.viewDelegate.displayError(error: error)
            })
        }
    }
}
