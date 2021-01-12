//
//  TransactionHistoryPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/27/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation

protocol TransactionHistoryViewPresentation: BasePresentation, NetworkRequestPresentable {
    
    func displayError(error:AppError)
    func displayTransactionHistory()
    func displaySuccessMessage()
    
}

class TransactionHistoryPresenter {
    
    private var viewDelegate: TransactionHistoryViewPresentation!
    
    private var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    var transactionModels = [TransactionHistoryModel]()
    
    init(controller: TransactionHistoryViewPresentation) {
        self.viewDelegate = controller
        self.viewDelegate.setupViews()
    }
    
    
    func deleteTransaction(index: Int){
        let transaction  = self.transactionModels[index]
        print(transaction.id)
        print(transaction.title)
        print(transaction.voucherId)
        self.viewDelegate.showLoadingIndicator()
        ApiManager.sendRequest(toApi: .deleteTransaction(transactionID: transaction.id), onSuccess: {
            status , response in
            self.viewDelegate.hideLoadingIndicator()
            print(status)
            print(response)
           
            if status == 200 {
                self.viewDelegate.displaySuccessMessage()
            }else{
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: "Transaction could not be deleted."))
            }
            
            
        }, onError: {
            error in
            
        })
    }
    
    func fetchTransactionHistory() {
        
        self.viewDelegate.showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.transactionHistory, onSuccess: { (statusCode, data) in
            
            self.viewDelegate.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                
                if !isErrorPresent {
                    
                    if let transactionObjects = data["data"].array {
                        
                        var models = [TransactionHistoryModel]()
                        
                        for eachObject in transactionObjects {
                                                        let noOfPurchases = eachObject["number_of_credits"].int ?? 0
                            let title = eachObject["status"].string ?? ""
                            let transactionId = eachObject["transaction_id"].string ?? ""
                            let statusFlag = eachObject["status_flag"].int ?? 0
                            let date = eachObject["date"].string ?? ""
                            let id = eachObject["id"].int ?? 0
                            let history = TransactionHistoryModel(id: id,title: title, numberOfPurchases: noOfPurchases, voucherId: transactionId, date: date, type: statusFlag)
                            models.append(history)
                        }
                        
                        self.transactionModels = models
                        self.viewDelegate.displayTransactionHistory()
                    }
                    
                } else {
                    
                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    self.viewDelegate.hideLoadingIndicator()
                    self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
                }
                
                
            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.viewDelegate.hideLoadingIndicator()
                
                self.viewDelegate.displayError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.displayError(error: ApiError.invalidResponse(message: error.localizedDescription))
        }
    }
    
}

struct TransactionHistoryModel {
    var id:Int
    var title:String
    var numberOfPurchases:Int
    var voucherId:String
    var date:String
    var type:Int
}
