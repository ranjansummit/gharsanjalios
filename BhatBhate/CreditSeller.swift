//
//  CreditSeller.swift
//  BhatBhate
//
//  Created by Nishan-82 on 12/21/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import GoogleMaps

enum CreditSellerType: Int {
    case shop = 1
    case user = 0
}

struct CreditSeller {
    
    var id:Int?
    var name:String?
    var mobile:String?
    var email:String?
    var availableCredit: Int?
    var type: CreditSellerType
    var latitude: Double?
    var longitude: Double?
    var location: String?
    var imageUrl:String?
    
    init(json: JSON) {
        let shopType = json["shop"].int ?? 0
        id = shopType == 1 ? json["id"].int : Int(json["id"].string!)
        name = json["name"].string
        mobile = json["mobile"].string
        email = json["email"].string
        availableCredit = shopType == 1 ? json["available_credit"].int :  Int(json["available_credit"].string!)
        type = CreditSellerType(rawValue: shopType)!
        latitude = shopType == 1 ? json["latitude"].double : Double(json["latitude"].string!)
        longitude = shopType == 1 ? json["longitude"].double : Double(json["longitude"].string!)
        location = json["location"].string
        imageUrl = json["image"].string
    }
    
}

