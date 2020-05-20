//
//  Api.swift
//  customer
//
//  Created by Nishan-82 on 7/6/17.
//  Copyright © 2017 sunil. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyUserDefaults
struct Api  {
    
    /*
     ********************* Warning *********************
     1. Uat and live api :- check constants.swift
     2. Live and test esewa :- check Constants.esewa and CreditPurchaseConfirmationViewController
     
     
     */
     // Check in constants.swift also
    //static let BASE_URL = "http://bhatbhate.net/"
  //  static let BASE_URL = "http://uat.bhatbhate.net/"
    
    
    static var BASE_URL:String{
        return Constants.schemeDevelopment ? "http://uat.bhatbhate.net" : "http://bhatbhate.net"
    }
    
    enum Endpoint {
        case registerUser(params: [String:Any])
        case getToken(params: [String:Any])
        case enableUser(params: [String:Any])
        case verifyMobile(params:[String:Any])
        case accessToken
        case refreshToken
        case forgotPassword(params:[String:Any])
        case changePassword(params:[String:Any])
        case resendCode(params:[String:Any])
        case getVehicles(filter:String,offset:Int,limit:Int)
        case preLoginVehicles(offset:Int,limit:Int)
        case getVehicleProperties
        case vehicleDetails(id:Int)
        case addToWishlist(bikeId:Int)
        case removeFromWishlist(bikeId:Int)
        case searchBike(brand:String,model:String,price:String,condition:Int,offset:Int,limit:Int,isOwn:Bool)
        case preLoginSearchBike(brand:String,model:String,price:String,condition:Int,offset:Int,limit:Int)
        case getProfile
        case editProfile(name:String,mobile:String,newPassword:String?,confirmPassword:String?)
        case saveImage
        case saveBike
        case shopList(latitude:Double,longitude:Double)
        
        // Notification
        case notificationsFromSeller
        case notifySeller(vehicleId:Int,notificatinID:Int?) //notification id is for resending request from notification                                after expiration
        case sellerInformation(vehicleId:Int)
        case transactionHistory
        case deleteTransaction(transactionID:Int)
        case notificationFromBuyer
        case changeBikeNotificationStaus(status:Int,vehicleID:Int,filter:String,notificationId:Int)
        case changeCreditNotificationStatus(response:Int,notificationId:Int,filter: String)
        
        case creditRequest(sellerId:Int,credit:Int)
        
        case generateQR(credit:Int)
        case purchaseCredit(qrCode: String, id:Int)
        case purchaseViaCode(code:String)
        case updateFCMToken(token: String)
        case updateUserLocation(latitude:Double,longitude:Double,location:String) //location
        case sendActivationCode(email:String,mobile:String)
        case publishBike(bikeID:Int)
        case getProductIDForEsewa(credit:Int , rate:Int)
        case getCredit
        case AllNotification
        case ResetNotification
        case AppSetting
        case Logout(fcmToken:String)
        case DeleteVehicle(vehicleID : Int)
        case MarkAsSold(VehicleID: Int)
        case EditVehiclePrice(vehicleID:Int, price:Int)
        case CouponCode(code:String)
        //MARK:- Api endpoint url
        var url:String {
            
            switch self {
                
            case .registerUser(_):
                return BASE_URL + "/api/v1/users"
            case .getToken:
                return BASE_URL + "/api/v1/users/token"
            case .enableUser:
                return BASE_URL + "/api/v1/users/activate"
            case .verifyMobile:
                return BASE_URL + "/api/v1/users/verify_mobile"
            case .accessToken:
                return BASE_URL + "/randomAccessTokenURL"
            case .refreshToken:
                return BASE_URL + "/api/v1/token/refresh"//"/randomRefreshTokenURL"
            case .forgotPassword:
                return BASE_URL + "/api/v1/forget/password"
            case .changePassword:
                return BASE_URL + "/api/v1/change/password"
            case .resendCode:
                return BASE_URL + "/api/v1/resend/code"
            case .getVehicles(let filter,_,_):
                return BASE_URL + "/api/v1/vehicles/filter/\(filter)"
                case .preLoginVehicles(_,_):
                return BASE_URL + "/api/v1/vehicle/prelogin"
                
            case .getVehicleProperties:
                return BASE_URL + "/api/v1/vehicles/properties"
                
            case .vehicleDetails(let id):
                return BASE_URL + "/api/v1/vehicles/\(id)"
                
            case .addToWishlist(let bikeId):
                return BASE_URL + "/api/v1/wishlist/add/\(bikeId)"
                
            case .removeFromWishlist(let bikeId):
                return BASE_URL + "/api/v1/wishlist/remove/\(bikeId)"
                
            case .searchBike:
                return BASE_URL + "/api/v1/search"
                
            case .preLoginSearchBike:
                return BASE_URL + "/api/v1/search/prelogin"
                
            case .getProfile:
                return BASE_URL + "/api/v1/profile"
                
            case .editProfile:
                return BASE_URL + "/api/v1/profile/edit"
                
            case .saveImage:
                return BASE_URL + "/api/v1/user/image"
                
            case .notificationsFromSeller:
                return BASE_URL + "/api/v1/notification/seller"
            
            case .notificationFromBuyer:
                return BASE_URL + "/api/v1/notification/buyer"
                
            case .notifySeller:
                return BASE_URL + "/api/v1/notify-seller"
                
            case .changeBikeNotificationStaus(let status,_,_,_):
                return BASE_URL + "/api/v1/notifications/\(status)"
                
            case .changeCreditNotificationStatus(_,let notificationId,_):
                return BASE_URL + "/api/v1/shop-notification/\(notificationId)"
                
            case .sellerInformation(let vehicleId):
                return BASE_URL + "/api/v1/notification/seller-info/\(vehicleId)"
                
            case .transactionHistory:
                return BASE_URL + "/api/v1/transactions"
            case .deleteTransaction:
                return BASE_URL + "/api/v1/transaction/delete"
            case .saveBike:
                return BASE_URL + "/api/v1/vehicles"
            case .publishBike:
                return BASE_URL + "/api/v1/publish-vehicle"
            case .shopList:
                return BASE_URL + "/api/v1/shops"
                
            case .creditRequest:
                return BASE_URL + "/api/v1/shop-notification"
                
            case .generateQR:
                return BASE_URL + "/api/v1/qr-codes"
                
            case .purchaseCredit(let qrCode, _):
                return BASE_URL + "/api/v1/qr-codes/\(qrCode)"
                
            case .purchaseViaCode:
                return BASE_URL + "/api/v1/via-code"
                
            case .updateFCMToken:
                return BASE_URL + "/api/v1/save-fcm-token"
                
            case .sendActivationCode:
                return BASE_URL + "/api/v1/users/activation-code"
                
            case .updateUserLocation:
                return BASE_URL + "/api/v1/location"
                
            case .getProductIDForEsewa:
                return BASE_URL + "/api/v1/gen-productid"
                
            case .getCredit:
                return BASE_URL + "/api/v1/usercredit"
            case .AllNotification:
                return BASE_URL + "/api/v1/notification/all"
            case .ResetNotification:
                return BASE_URL + "/api/v1/notification/all?seen=1"
            case .AppSetting:
                return BASE_URL + "/api/v1/app/setting"
            case .Logout(let token):
                return BASE_URL + "/api/v1/user/logout?fcm_token=\(token)"
            case .DeleteVehicle(let id):
                return BASE_URL + "/api/v1/vehicles/\(id)"
            case .MarkAsSold(let id):
                return BASE_URL + "/api/v1/vehicle/sold/\(id)"
            case .EditVehiclePrice:
                return BASE_URL + "/api/v1/vehicle/price/edit"
            case .CouponCode:
                return BASE_URL + "/api/v1/user/coupon"
            }
        }
        
        // MARK:- Request method
        var method:HTTPMethod {
            
            switch self {
            case .accessToken,.refreshToken,.editProfile,.saveImage,.notifySeller,.registerUser,.enableUser,.verifyMobile,.getToken,.resendCode,.saveBike,.creditRequest,.generateQR,.updateFCMToken,.sendActivationCode,.publishBike,.updateUserLocation,.forgotPassword,.changePassword,.purchaseViaCode,.EditVehiclePrice,.CouponCode:
                
                return HTTPMethod.post
            case .changeCreditNotificationStatus,.changeBikeNotificationStaus,.purchaseCredit:
                return HTTPMethod.put
            case .DeleteVehicle:
                return .delete
            default:
                return HTTPMethod.get
            }
        }
        
        // MARK:- Request Parameter
        var parameters:[String:Any]? {
            
            switch self {
            case .registerUser(let params):
                return params
            case .getToken(let params):
                return params
            case .enableUser(let params):
                return params
            case .verifyMobile(let params):
                return params
            case .forgotPassword(let params):
                return params
            case .changePassword(let params):
                return params
            case .resendCode(let params):
                return params
            case .getVehicles(_, let offset,let limit):
                
                var params = [String:Any]()
                params["offset"] = offset
                params["limit"] = limit
                return params
            case .preLoginVehicles(let offset, let limit):
                var params = [String:Any]()
                params["client_id"] = Constants.clientId
                params["client_secret"] = Constants.clientSecret
                params["offset"] = offset
                params["limit"] = limit
                return params
            case .searchBike(let brand, let model, let price, let condition, let offset,let limit, let isOwn):
                
                var params = [String:Any]()
                if isOwn {
                    params["own"] = 1
                }
                params["brand"] = brand
                params["model"] = model
                params["price"] = price == "0" ? "" : price
                params["offset"] = offset
                params["limit"] = limit
                params["rating"] = condition == 100 ? "" : condition.description
                return params
                
              case  .preLoginSearchBike(let brand, let model, let price, let condition, let offset,let limit):
                var params = [String:Any]()
                params["client_id"] = Constants.clientId
                params["client_secret"] = Constants.clientSecret
                params["brand"] = brand
                params["model"] = model
                params["price"] = price == "0" ? "" : price
                params["offset"] = offset
                params["limit"] = limit
                params["rating"] = condition == 100 ? "" : condition.description
                return params
                
            case .editProfile(let name, let mobile,let newPassword,let confirmPassword):
                
                var params = [String:Any]()
                params["name"] = name
                params["mobile"] = mobile
                params["password"] = newPassword
                params["password_confirmation"] = confirmPassword
                
                return params
                
            case .changeBikeNotificationStaus(_ , let vehicleID,let filter,let notificationId):
                return ["vehicle_id":vehicleID,"filter":filter,"notification_id":notificationId]
                
            case .changeCreditNotificationStatus(let response,_,let filter):
                return ["status":response, "filter":filter]
                
            case .notifySeller(let vehicleId, let notifID):
                var params = [String:Any]()
                params["vehicle_id"] = vehicleId
                if let notificationID = notifID {
                    params["id"] = notificationID
                }
                return params
            case .deleteTransaction(let transactionID):
                return ["transaction_id":transactionID]
            case .shopList(let latitude, let longitude):
                
                var params = [String:Any]()
                params["latitude"] = latitude
                params["longitude"] = longitude
                return params
                
            case .creditRequest(let sellerId,let credit):
                
                var params = [String:Any]()
                params["seller_id"] = sellerId
                params["credit"] = credit
                return params
                
            case .generateQR(let credit):
                
                var params = [String:Any]()
                params["credit"] = credit
                return params
                
            case .updateFCMToken(let token):
                
                return ["fcm_token":token]
                
            case .purchaseCredit(_,let id):
                return ["id":id]
                
            case .purchaseViaCode(let code):
                return ["via_code":code]
                
            case .sendActivationCode(let email,let mobile):
                
                return ["email":email,"mobile":mobile]
                
            case .publishBike(let bikeID):
                
                return ["id":bikeID]
                
            case .updateUserLocation(let latitude,let longitude, let location):
                return ["latitude":latitude,"longitude":longitude,"location":location]
                
            case .getProductIDForEsewa(let credit, let  rate):
                return ["credit":credit,"rate":rate]
            case .EditVehiclePrice(let vehicleID,let price):
                return ["id":vehicleID,"price":price]
            case .CouponCode(let code):
                return ["coupon":code]
                
            default:
                return nil
            }
        }
        
        // MARK:- Http Headers
        var headers:HTTPHeaders {
            get {
                var params = [String:String]()
                params["Content-Type"] = "application/json"
                params["Accept"] = "application/json"
                switch self {
                case .accessToken,.refreshToken,.addToWishlist,.removeFromWishlist,.searchBike,.preLoginSearchBike,.getProfile,.editProfile,.saveImage,.notificationsFromSeller,.vehicleDetails,.notifySeller,.sellerInformation,.transactionHistory,.getVehicleProperties,.shopList,.saveBike,.notificationFromBuyer,.changeBikeNotificationStaus,.getVehicles,.preLoginVehicles,.creditRequest,.generateQR,.changeCreditNotificationStatus,.updateFCMToken,.purchaseCredit,.sendActivationCode,.publishBike,.updateUserLocation,.getProductIDForEsewa,.getCredit,.verifyMobile,.deleteTransaction,.AllNotification,.ResetNotification,.purchaseViaCode,.AppSetting,.Logout,.DeleteVehicle,.MarkAsSold,.EditVehiclePrice,.CouponCode:
                    
                    params["Authorization"] = "Bearer \(Defaults[.accessToken] ?? "")"// BEARER_TOKEN_BUYER
                    return params
                    
                default:
                    return params
                }
                
            }
            
            set { }
        }
        
        // MARK:- Encoding
        var encoding:ParameterEncoding {
            
            switch self {
            case .getVehicles,.preLoginVehicles,.searchBike,.preLoginSearchBike,.shopList,.getProductIDForEsewa,.deleteTransaction:
                return URLEncoding.default
            default:
                return JSONEncoding.default
            }
        }
        
    }
}
