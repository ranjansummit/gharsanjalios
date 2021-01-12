//
//  ApiManager.swift
//  customer
//
//  Created by Nishan-82 on 7/6/17.
//  Copyright © 2017 sunil. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyUserDefaults

class ApiManager {
    
    fileprivate static var currentApiEndpoint:Api.Endpoint!
    fileprivate static var currentHeader: HTTPHeaders!
    fileprivate static var successHandler: ((_ statusCode:Int,_ data:JSON)->())!
    fileprivate static var errorHandler: ((AppError)->())?
    
    class func sendRequest(toApi api:Api.Endpoint, onSuccess:@escaping (_ statusCode:Int,_ data:JSON)->(),onError:@escaping (AppError)->()) {
        
        self.currentApiEndpoint = api
        self.successHandler = onSuccess
        self.errorHandler = onError
        self.currentHeader = api.headers
        //Log.add(info: "Header Auth Token: \(Defaults[.accessToken])")
          Log.start(info: api.url)
        Alamofire.request(api.url, method: api.method, parameters: api.parameters, encoding: api.encoding, headers: api.headers).response { (dataResponse) in
            
            Log.start(info: api.url)
            Log.add(info: "Request parameter: \(String(describing: api.parameters))")
            Log.add(info: "Response Header: \(String(describing: dataResponse.response))")
            Log.add(info: "Error: \(String(describing: dataResponse.error))")
            Log.add(info: "Response Data: \(String(describing: try? JSON(data:dataResponse.data!)))")
            Log.clear()
            
            if let error = dataResponse.error {
                
                Log.error(info: error)
                
                
                let message = error.localizedDescription
                
                Log.add(info: message)
                onError(ApiError.invalidResponse(message: message))
                return
            }
            
            // Intercepting token error
            guard let statusCode = dataResponse.response?.statusCode, statusCode != 401 else {
              //  refreshAccessToken()
                 let bikeCount = Defaults[.bikeCount]
                Defaults.removeAll()
                Defaults.synchronize()
                Defaults[.bikeCount] = bikeCount
                // Show Login Screen
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.showLoginScreen()
                onError(ApiError.invalidResponse(message: "Error occurred"))
                return
            }
            
            // If there is no token error
            if let data = dataResponse.data {
                
                let jsonData = JSON(data)
                onSuccess(statusCode,jsonData)
            }
        }
    }
    
    /*
     Request for new access token from the server
     */
    fileprivate class func refreshAccessToken() {
        
        var parameters = [String:Any]()
        parameters["grant_type"] = "refresh_token"
        parameters["refresh_token"] = Defaults[.refreshToken]
        parameters["client_id"] = Constants.clientId
        parameters["client_secret"] = Constants.clientSecret
        
        let url = Api.Endpoint.refreshToken.url
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).response { (dataResponse) in
            
            Log.start(info: url)
            Log.add(info: "Request parameter: \(String(describing: parameters))")
            Log.add(info: "Response Header: \(String(describing: dataResponse.response))")
            Log.add(info: "Error: \(String(describing: dataResponse.error))")
            Log.add(info: "Response Data: \(String(describing: try? JSON(data:dataResponse.data!)))")
            Log.clear()
            
            if let error = dataResponse.error {
                clearApiInfo()
                errorHandler?(ApiError.invalidResponse(message: error.localizedDescription))
                return
            }
            
            guard let statusCode = dataResponse.response?.statusCode else {
                
                clearApiInfo()
                errorHandler?(CustomError.standard)
                return
            }
            
            if statusCode == 200 {
                
                let data = JSON(dataResponse.data!)
                let accessToken = data["data"]["access_token"].string!
                let refreshToken = data["data"]["refresh_token"].string!
                
                Defaults[.accessToken] = accessToken
                Defaults[.refreshToken] = refreshToken
                
                var newHeader = currentHeader
                newHeader!["Authorization"] = accessToken
                
                self.currentApiEndpoint.headers = newHeader!
                
                self.sendRequest(toApi: self.currentApiEndpoint, onSuccess: successHandler, onError: errorHandler!)
                
            } else if statusCode == 401 {
                LoadingIndicatorView.hide()
                clearApiInfo()
                 let bikeCount = Defaults[.bikeCount]
                // TODO:- Handle logout here
                // Remove all stored values
                Defaults.removeAll()
                Defaults.synchronize()
                Defaults[.bikeCount] = bikeCount
                // Show Login Screen
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.showLoginScreen()
                return
            }
        }
    }
    
    fileprivate class func clearApiInfo() {
        currentApiEndpoint = nil
        successHandler = nil
        errorHandler = nil
    }
    
}
