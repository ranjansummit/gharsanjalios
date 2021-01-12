//
//  BuyNotificationViewModel.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/22/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import SwiftyJSON

enum NotificationSection: Int {
    
    case bikeNotification = 1
    case creditNotification = 2
    case allNotification = 0
    case bikeSellNotification = 3
    
}

enum BikeNotificationStatus:Int {
    
    case sent = 0
    case accepted = 1
    case expired = 2
    case rejected = 3
    
    var description:String {
        
        switch self {
        case .sent:
            return "Request sent:"
        case .accepted:
            return "Info received:"
        case .expired:
            return "Request expired:"
        case .rejected:
            return "Request rejected:"
        }
    }
    
    var descriptionForSeller: String {
        
        switch self {
        case .sent:
            return "Request received"
        case .accepted:
            return "Request accepted"
        case .expired:
            return "Request expired"
        case .rejected:
            return "Request Rejected"
        }
    }
    
    // status of vehicle:set 1 for accepted,2 for expired,3 for decline
}

enum CreditNotificationStatus: Int {
    
    case sent = 0
    case accepted = 1
    case expired = 2
    case rejected = 3
    
    var descriptionForBuyer:String {
        
        switch self {
        case .sent:
            return "request sent:"
        case .accepted:
            return "request accepted:"
        case .expired:
            return "request expired:"
        case .rejected:
            return "request declined:"
        }
    }
    
    var descriptionForSeller: String {
        
        switch self {
        case .sent:
            return "request received"
        default:
            return descriptionForBuyer
        }
    }
    // 0: sent, 1, accepted, 2 expired, 3 decline
}

struct CreditNotification {
    
    enum Key: String {
        
        case status = "status"
        case id = "id"
        case creditQuantity = "credit"
        case requestedTo = "requested_to"
        case description = "description"
        
        case requestedBy = "requested_by"
        case buyerMobileNumber = "mobile"
        case buyerLatitude = "latitude"
        case buyerLongitude = "longitude"
        case buyerLocation = "location"
        case buyerMessage = "message"
        case imageURL = "image_url"
    }
    
    var id: Int?
    var status: CreditNotificationStatus = .sent
    var description: String?
    var creditQuantity: Int?
    var sellerName: String?     // requested_to
    var buyerName: String?      // requested_by
    var buyerMobileNumber: String?
    var buyerLocation: String?
    var buyerLatitude: Double?
    var buyerLongitude: Double?
    var buyerImage: String?
    
    init(json: JSON) {
        
        id = json[Key.id.rawValue].int
        
        let requestStatus = json[Key.status.rawValue].string ?? "0"
        let requestStatusInInt = Int(requestStatus)!
        status = CreditNotificationStatus(rawValue: requestStatusInInt)!
        
        description = json[Key.description.rawValue].string
        creditQuantity = json[Key.creditQuantity.rawValue].int
        sellerName = json[Key.requestedTo.rawValue].string
        
        // If notification is to be shown to seller
        buyerName = json[Key.requestedBy.rawValue].string
        buyerMobileNumber = json[Key.buyerMobileNumber.rawValue].string
        buyerLocation = json[Key.buyerLocation.rawValue].string
        buyerLatitude = json[Key.buyerLatitude.rawValue].double
        buyerLongitude = json[Key.buyerLongitude.rawValue].double
        buyerImage = json[Key.imageURL.rawValue].string
        guard let _ = description else {
            self.description = json[Key.buyerMessage.rawValue].string
            return
        }
    }
}

struct AllNotification {
    enum Key:String,Codable {
        case status = "status"
        case creditQuantity = "credit"
        case requestedTo = "requested_to"
        case description = "description"
        case requestedBy = "requested_by"
        case buyerMobileNumber = "mobile"
        case buyerLatitude = "latitude"
        case buyerLongitude = "longitude"
        case buyerLocation = "location"
        case buyerMessage = "message"
        case imageURL = "image_url"
        case sellerName = "seller_name"
        case vehicleName = "vehicle_name"
        case vehicleId = "vehicle_id"
        case imageUrl = "front_side_image"
        case buyerName = "buyer_name"
        case notificationId = "id"
        case type = "type"
    }
    
    var status: BikeNotificationStatus = .sent
    var description: String?
    var creditQuantity: Int?
    var sellerName: String?     // requested_to
    var buyerName: String?      // requested_by
    var buyerMobileNumber: String?
    var buyerLocation: String?
    var buyerLatitude: Double?
    var buyerLongitude: Double?
    var buyerImage: String?
    var id: Int?
    var vehicleName:String?
    var vehicleId:Int?
    var imageUrl:String?
    var type:String?
    
    init(json: JSON) {
        
        id = json[Key.notificationId.rawValue].int
        buyerName = json[Key.buyerName.rawValue].string
        sellerName = json[Key.sellerName.rawValue].string
        vehicleName = json[Key.vehicleName.rawValue].string
        vehicleId = json[Key.vehicleId.rawValue].int
        type = json[Key.type.rawValue].string
        let requestStatus = json[Key.status.rawValue].string ?? "0"
        let requestStatusInInt = Int(requestStatus)!
        
        status = BikeNotificationStatus(rawValue: requestStatusInInt)!
        
        imageUrl = json[Key.imageUrl.rawValue].string
        description = json[Key.description.rawValue].string
        
        
        if type == "credit" {
            description = json[Key.description.rawValue].string
            creditQuantity = json[Key.creditQuantity.rawValue].int
            sellerName = json[Key.requestedTo.rawValue].string
            
            // If notification is to be shown to seller
            buyerName = json[Key.requestedBy.rawValue].string
            buyerMobileNumber = json[Key.buyerMobileNumber.rawValue].string
            buyerLocation = json[Key.buyerLocation.rawValue].string
            buyerLatitude = json[Key.buyerLatitude.rawValue].double
            buyerLongitude = json[Key.buyerLongitude.rawValue].double
            buyerImage = json[Key.imageURL.rawValue].string
            guard let _ = description else {
                self.description = json[Key.buyerMessage.rawValue].string
                return
            }
        }
       
      
    }
}

struct BikeNotification {
    
    enum Key:String,Codable {
        
        case sellerName = "seller_name"
        case vehicleName = "vehicle_name"
        case vehicleId = "vehicle_id"
        case status = "status"
        case imageUrl = "front_side_image"
        case description = "description"
        case buyerName = "buyer_name"
        case notificationId = "id"
        case type = "type"
    }
    
    var id: Int?
    var sellerName:String?
    var vehicleName:String?
    var vehicleId:Int?
    var status: BikeNotificationStatus = .sent
    var imageUrl:String?
    var description:String?
    var buyerName:String?
    var type:String?
    
    init(json: JSON) {
        
        id = json[Key.notificationId.rawValue].int
        buyerName = json[Key.buyerName.rawValue].string
        sellerName = json[Key.sellerName.rawValue].string
        vehicleName = json[Key.vehicleName.rawValue].string
        vehicleId = json[Key.vehicleId.rawValue].int
        type = json[Key.type.rawValue].string
        let requestStatus = json[Key.status.rawValue].string ?? "0"
        let requestStatusInInt = Int(requestStatus)!
        
        status = BikeNotificationStatus(rawValue: requestStatusInInt)!
        
        imageUrl = json[Key.imageUrl.rawValue].string
        description = json[Key.description.rawValue].string
    }
}


/// All the notification that should be displayed to buyer
struct BhatbhateUserNotification {
    
    var bikeNotifications:[BikeNotification]?
    var sellBikeNotifications:[BikeNotification]?
    var creditNotifications:[CreditNotification]?
    var allNotifications:[AllNotification]?
    init(json: JSON) {
       // print(json)
        if let creditInfo = json["credit_notifications"].array {
            creditNotifications = creditInfo.map{ CreditNotification(json: $0) }
          
        }
        
        if let allNotifInformation = json["All_notification"].array{
            allNotifications = allNotifInformation.map{AllNotification(json: $0)}
          
        }
        
        
        if let vehicleRequestInfo = json["vehicle_notifications"]["buy"].array {
            bikeNotifications = vehicleRequestInfo.map{ BikeNotification(json: $0) }
          
        }
        if let vehicleRequestInfo = json["vehicle_notifications"]["sell"].array {
            sellBikeNotifications = vehicleRequestInfo.map{ BikeNotification(json: $0) }
          
        }
    }    
}

/*** Notifications from Seller ***
 
 {
  "data" : {
    "credit_notifications" : [
      {
        "description" : "You have requested Mahendra Paud for 1 credit. This request will expire on 2018-01-12(9 days)",
        "status" : "0",
        "id" : 3,
        "credit" : 1,
        "requested_to" : "Mahendra Paud"
      }
    ],
    "vehicle_notifications" : [
      {
        "description" : "You have requested the information for the bike R15. This request will expire on 2018-01-12(9 days)",
        "status" : "0",
        "front_side_image" : "http:\/\/bhatbhate.net\/storage\/vehicle_images\/OnUuE4LfutGUYTkiIorN4l1mpfTxiuoJ29WRjlev.jpeg",
        "seller_name" : "Mahendra Paud",
        "vehicle_name" : "R15",
        "vehicle_id" : 4
      },
      {
        "description" : "Sunil Maharjan has sent his contact information for your interest in purchase of bike R15",
        "status" : "1",
        "front_side_image" : "http:\/\/bhatbhate.net\/storage\/vehicle_images\/tr7SAFFNauLI7O0KwxGMxJ8zt4ZiQxoYypBCoPFA.jpeg",
        "seller_name" : "Sunil Maharjan",
        "vehicle_name" : "R15",
        "vehicle_id" : 6
      }
    ]
  },
  "error" : false
}
 
 // *** Notifications from Buyer ***
 
 {
  "error": false,
  "data": [
    {
      "vehicle_notifications": [
        {
          "vehicle_id": 8,
          "buyer_name": "Mahendra_b",
          "vehicle_name": "R15",
          "status": "0",
          "front_side_image": "http://localhost/bhatbhate-api/public/storage/vehicle_images/HJOfJAfga9XNmO4PIByyWnPq10M6xRYgf441W71V.jpeg",
          "description": "Mahendra_b has shown interest in your bike R15 and would like your contact information"
        }
      ],
      "credit_notifications": [
        {
          √ "id": 1,
          "requested_by": "Mahendra_b",
          "mobile": "98415068788",
          "latitude": 44.4444,
          "longitude": 99.9999,
          "location": "",
          √ "credit": 5,
          √ "status": "0",
          "message": "Mahendra_b has requested for 5 credits"
        }
      ]
    }
  ]
}
 
 */
