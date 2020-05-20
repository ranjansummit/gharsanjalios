//
//  BikeSearchFilterPresenter.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/18/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SearchFilterViewModel {
    var id:Int
    var value:String
}

protocol BikeSearchFilterViewPresentation:class {
    
    func setupViews()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showError(error:AppError)
    func showMessage(message:String)
    
    func updatePriceLabel(price:String)
    func updateBrandLabel(brand:String)
    func updateModelLabel(model:String)
    func updateStarRating(condition:Int)
}

class BikeSearchFilterPresenter {
    
    weak var viewDelegate:BikeSearchFilterViewPresentation!
    
    private var selectedBrandIndex:Int = -1
    private var selectedModelIndex:Int = -1
    private var selectedPrice:Int = -1
    private var selectedContditon:Int = 1
    var brandList = [Brand]()
    var searchHistory:(brand: String, model: String, price: String,condition:Int)?
    init(viewDelegate:BikeSearchFilterViewPresentation) {
        self.viewDelegate = viewDelegate
        self.viewDelegate.setupViews()
    }
    
    /**
     This returns brandlist, model list, engine capacity list for search/filter page
    
     
     */
    func fetchSearchFilter() {
        self.viewDelegate.showLoadingIndicator()
        ApiManager.sendRequest(toApi: .getVehicleProperties, onSuccess: { [weak self](statusCode, response) in
            
            switch statusCode {
                
            case 200:
                
                self?.viewDelegate.hideLoadingIndicator()
                
                let isErrorPresent = response["error"].bool ?? true
                if !isErrorPresent {
                    
                    if let brandResponse = response["data"]["brands"].array {
                        
                        let brands = brandResponse.map{ Brand(json: $0) }
                        self?.brandList = brands
                    }
                    var price = "Any"
                    var brand = "Any"
                    var model = "Any"
                    var condition = 5
                    if let history = self?.searchHistory {
                        self?.selectedBrandIndex = self?.brandList.index(where: {$0.brandName == history.brand}) ?? -1
                        if self?.selectedBrandIndex != -1 {
                            let models = self?.brandList[(self?.selectedBrandIndex)!].models
                            self?.selectedModelIndex = models?.index(where: {$0.modelName == history.model}) ?? -1
                        }
                        
                        brand = history.brand == "" ? "Any" : history.brand
                        model = history.model == "" ? "Any" : history.model
                        if history.price == "" || history.price == "0" {
                            price = "Any"
                        }else {
                            price = history.price
                        }
//                        price = history.price == "" ? "Any" : history.price
                        condition = history.condition
                        if price != "Any" {
                            self?.selectedPrice = Int(price)!/100000
                            price = "< \(self?.selectedPrice ?? 1) Lakh\(self?.selectedPrice == 1 ? "" : "s")"
                        }
                    }else{
                        condition = 100
                    }
                    self?.viewDelegate.updatePriceLabel(price: price)
                    self?.viewDelegate.updateBrandLabel(brand: brand)
                    self?.viewDelegate.updateModelLabel(model: model)
                    self?.viewDelegate.updateStarRating(condition: condition)
                    
                } else {
                    
                    let message = response["message"].string ?? CustomError.standard.localizedDescription
                    self?.viewDelegate.showError(error: ApiError.invalidResponse(message: message))
                }
                
            default:
                
                self?.viewDelegate.hideLoadingIndicator()
                let message = response["message"].string ?? CustomError.standard.localizedDescription
                self?.viewDelegate.showError(error: ApiError.invalidResponse(message: message))
            }
            
        }) { (error) in
            
            self.viewDelegate.hideLoadingIndicator()
            self.viewDelegate.showError(error: error)
        }        
    }
  
    
    func updatePriceFilter(currentValue:Float) {
        var price:String!
        selectedPrice = Int(currentValue)
        price = "< \(selectedPrice) Lakh\(selectedPrice == 1 ? "" : "s")"
        if selectedPrice == 0 {
            price = "Any"
        }
        print("price1= ",price)
        viewDelegate.updatePriceLabel(price: price)
    }
    
    func setCondtionFilter(condition:Int){
        
    }
    /*--------------------------
     MARK:- Picker Helpers
     Tag 1: Brand List
     Tag 2: Model List
     ---------------------------*/
    
    func shouldShowFilterOptions(tag:Int) -> Bool {
        
        if tag == 1 {
            
            if brandList.count == 0 {
                self.viewDelegate.showError(error: CustomError.with(message: "No brands are available"))
                return false
            }
            return true
            
        } else {
            
            if selectedBrandIndex == -1 {
                self.viewDelegate.showError(error: CustomError.with(message: "Please select brand first"))
                return false
            }
            return true
        }
    }
    
    func optionCountForFilter(tag:Int) -> Int {
        
        if tag == 1 {
            return brandList.count + 1
        } else {
            return selectedBrandIndex == -1 ? 0 : brandList[selectedBrandIndex].models!.count + 1
        }
    }
    
    func optionForFilter(tag:Int,row:Int) -> String {
        if row == 0 {
            return "Any"
        }
        if tag == 1 {
            return brandList[row-1].brandName ?? ""
        } else if tag == 2 {
            let models = brandList[selectedBrandIndex].models
            return models?[row - 1].modelName ?? ""
        } else {
            return ""
        }
    }
    
    func setFilter(tag:Int,selectedOptionIndex:Int) {
        
        if tag == 1 {
            var brandName = "Any"
            self.selectedBrandIndex = selectedOptionIndex - 1
            if selectedBrandIndex != -1 {
                let brand = brandList[selectedBrandIndex]
                brandName =  brand.brandName ?? ""
            }
            selectedModelIndex = -1
            viewDelegate.updateBrandLabel(brand: brandName)
            
        } else if tag == 2 {
            
            self.selectedModelIndex = selectedOptionIndex - 1 // because of "Any"
            
            let models = brandList[selectedBrandIndex].models
            let selectedModel = selectedModelIndex == -1 ? "Any" : models?[selectedModelIndex].modelName
            
            viewDelegate.updateModelLabel(model: selectedModel ?? "")
        }
    }
    
    func getFilter() -> (brand:String,model:String,price:String,condition:Int) {
        
        let brand = selectedBrandIndex != -1 ? brandList[selectedBrandIndex].brandName ?? "" : ""
        let model = selectedModelIndex != -1 ? brandList[selectedBrandIndex].models?[selectedModelIndex].modelName ?? "" : ""
        let price = selectedPrice != -1 ? "\(selectedPrice * 100000)" : ""
        let condition = selectedContditon
        
        return (brand,model,price,condition)
    }
}

