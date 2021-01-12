//
//  Bike.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/16/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyJSON

class Bike {
    
    private enum Key:String,CodingKey {
        
        case id = "id"
        case brandName = "brand_name"
        case brandID = "brand_id"
        case modelName = "model_name"
        case modelID = "model_id"
        case engineCapacity = "engine_capacity"
        case engineCapacityID = "engine_capacity_id"
        case name = "vehicle_name"
        case mileage = "mileage"
        case frontImage = "front_side_image"
        case backImage = "back_side_image"
        case leftImage = "left_side_image"
        case rightImage = "right_side_image"
        case vehicleLot = "lot"
        case price = "price"
        case odometerReading = "odometer"
        case conditionRating = "rating"
        case wishlistId = "is_wishlist"
        case sellerName = "seller_name"
        case sellerImage = "seller_image"
        case publish = "publish"
        case buyerCount = "buyer_count"
        case wishCount = "wish_count"
        case isRequestSent = "is_request_sent"
        case isSold = "is_sold"
    }
    
    var id: Int?
    var brandName: String?
    var brandID: Int?
    var modelName: String?
    var modelID: Int?
    var engineCapacity: String?
    var engineCapacityID: Int?
    var name: String?
    var mileage: String?
    var imageURL: [String]?
    var image:[UIImage]?
    var vehicleLot: String?
    var price: String?
    var odometerReading: String?
    var conditionRating: Int?
    var sellerName: String?
    var sellerImage: String?
    var isInWishlist: Bool = false
    var isPublished: Bool = false
    var bikeFullName = ""
    var wishCount:Int?
    var buyerCount:Int?
    var isRequestSent:Bool = false
    var isSold:Bool = false
    init(dictBike:[String:Any]){
       // print(dictBike)
        self.brandName = dictBike[Key.brandName.rawValue] as? String
        self.brandID = dictBike[Key.brandID.rawValue] as? Int
        self.modelName = dictBike[Key.modelName.rawValue] as? String
        self.modelID = dictBike[Key.modelID.rawValue] as? Int
        self.engineCapacity = dictBike[Key.engineCapacity.rawValue] as? String
        self.engineCapacityID = dictBike[Key.engineCapacityID.rawValue] as? Int
        self.name = dictBike[Key.name.rawValue] as? String
        self.mileage = dictBike[Key.mileage.rawValue] as? String
        self.image = dictBike["images"] as? [UIImage]
        self.vehicleLot = dictBike[Key.vehicleLot.rawValue] as? String
        self.price = dictBike[Key.price.rawValue] as? String
        self.odometerReading = dictBike[Key.odometerReading.rawValue] as? String
        self.conditionRating = dictBike[Key.conditionRating.rawValue] as? Int
        self.sellerName = dictBike[Key.sellerName.rawValue] as? String
        self.sellerImage = dictBike[Key.sellerImage.rawValue] as? String
        self.bikeFullName = "\(self.brandName ?? "") \(self.modelName ?? "")"
        if let  wishlist = dictBike[Key.wishlistId.rawValue] as? Int {
            self.isInWishlist = wishlist == 1
        }
        if let publish = dictBike[Key.publish.rawValue] as? Int{
            self.isPublished = publish == 1
        }
        self.wishCount = dictBike[Key.wishCount.rawValue] as? Int
        self.buyerCount = dictBike[Key.buyerCount.rawValue] as? Int
        if let isReqSent = dictBike[Key.isRequestSent.rawValue] as? Int {
            self.isRequestSent = isReqSent == 1
        }
        if let sold = dictBike[Key.isSold.rawValue] as? String {
            self.isSold = sold == "yes"
        }
    }
    
    init(json: JSON) {
        
        self.id = json[Key.id.rawValue].int
        self.brandName = json[Key.brandName.rawValue].string
        self.brandID = json[Key.brandID.rawValue].int
        self.modelName = json[Key.modelName.rawValue].string
        self.modelID = json[Key.modelID.rawValue].int
        self.engineCapacity = json[Key.engineCapacity.rawValue].string
        self.engineCapacityID = json[Key.engineCapacityID.rawValue].int
        self.mileage = json[Key.mileage.rawValue].string
        
        let frontImage = json[Key.frontImage.rawValue].string ?? ""
        let backImage = json[Key.backImage.rawValue].string ?? ""
        let leftImage = json[Key.leftImage.rawValue].string ?? ""
        let rightImage = json[Key.rightImage.rawValue].string ?? ""
        
        self.name = "\(brandName ?? "") \(modelName ?? "")"
        
        self.imageURL = [frontImage,leftImage,rightImage,backImage]
        self.vehicleLot = json[Key.vehicleLot.rawValue].string
        
        let priceInDouble = json[Key.price.rawValue].double ?? 0.0
        let priceInString = String(format: "%.0f", priceInDouble)
        self.price = priceInString
        
        let odometerReadingInInt =  json[Key.odometerReading.rawValue].int
        self.odometerReading = "\(odometerReadingInInt ?? 0)"
        
        self.conditionRating = json[Key.conditionRating.rawValue].int
        self.sellerName = json[Key.sellerName.rawValue].string
        self.sellerImage = json[Key.sellerImage.rawValue].string
        self.bikeFullName = "\(self.brandName ?? "") \(self.modelName ?? "")"
        if let publish = json[Key.publish.rawValue].int {
            self.isPublished = publish == 1
        }
        if let wishlist = json[Key.wishlistId.rawValue].int {
            self.isInWishlist = wishlist == 1
        }
        self.wishCount = json[Key.wishCount.rawValue].int
        self.buyerCount = json[Key.buyerCount.rawValue].int
        if let reqSent = json[Key.isRequestSent.rawValue].int {
            self.isRequestSent = reqSent == 1
        }
        if let sold = json[Key.isSold.rawValue].string {
            self.isSold = sold == "yes"
        }
    }
}

