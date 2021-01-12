//
//  CreditQRCode.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/9/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import SwiftyJSON
import Foundation

struct CreditQRCode {
    
    struct Key {
        static let codeId = "codeId"
        static let sellerName = "sellerName"
        static let location = "location"
        static let creditQuantity = "creditQuantity"
        static let totalAmount = "totalAmount"
        static let rate = "rate"
        static let code = "code"
        static let sellerImageUrl = "sellerImageUrl"
    }
    
    let codeId:Int
    let sellerName:String
    let location:String
    let creditQuantity:Int
    let totalAmount: Double
    let rate:Double
    let code:String
    let sellerImageUrl:String
    init(codeId:Int,sellerName:String,location:String,creditQuantity:Int,totalAmount:Double,rate:Double,code:String,imageUrl:String) {
        
        self.codeId = codeId
        self.sellerName = sellerName
        self.location = location
        self.creditQuantity = creditQuantity
        self.totalAmount = totalAmount
        self.rate = rate
        self.code = code
        self.sellerImageUrl = imageUrl
    }
    
    
    func getQRCodeRepresentation() -> Data? {
        
        var dict = [String:Any]()
        dict[Key.codeId] = codeId
        dict[Key.sellerName] = sellerName
        dict[Key.location] = location
        dict[Key.creditQuantity] = creditQuantity
        dict[Key.totalAmount] = totalAmount
        dict[Key.rate] = rate
        dict[Key.code] = code
        dict[Key.sellerImageUrl] = sellerImageUrl
        
        do {
            let dataRepr = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            return dataRepr
            
        } catch let serializationError {
            
            Log.error(info: serializationError)
            return nil
        }
        
//
//        let strRepr = dict.description
//        let dataRepr = strRepr.data(using: String.Encoding.utf8, allowLossyConversion: false)
//
//        return dataRepr
    }
    
}
