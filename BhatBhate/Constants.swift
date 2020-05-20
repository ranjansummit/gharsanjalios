//
//  Constants.swift
//  BhatBhate
//
//  Created by sunil-71 on 2/24/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import Foundation
import Starscream
import EsewaSDK
struct Constants {
    
    static let schemeDevelopment = false // true for uat false for production
    
    static let clientId = 1
   
    static let webSocketURL = WebSocket(url: URL(string: "ws://staging.andmine.com:7979/")!)
    
    static var clientSecret:String{
        return schemeDevelopment ? "JzSUAyr1T6hy43x9X3InoEyMVrxnbryWlRKAP7CV" : "W8ZZci58qPeERpaIKyA38GDesnpTnXXxrNxxnIL2"
    }
     
    static var esewaRedirectURL:String{
        return schemeDevelopment ? "http://uat.bhatbhate.net/api/v1/esewa/redirect" : "http://bhatbhate.net/api/v1/esewa/redirect"
    }
    
    struct Esewa {
        static let sandbox = false // true for test account false for real account
        static var merchantID:String { return Esewa.sandbox ? "KBYXFAkSBRFZMRYWA1sHDhYNCBYXFAkSBRE=" : "JxsEAwMbChEcXz01WiQgRicxJCcnPyAnLg=="}
        static var merchantSecret:String{return Esewa.sandbox ? "ERYWA08QBAhXERYWA08QBAhXERYWA08QBAg=" : "DQcRB1tcRAcRBAcHHwAHDksXAAdLFA4eRQscEV0HHwAHCQ0YERY=" }
        static var environment: EsewaSDKEnvironment{
            return sandbox ? .development : .production
        }
    }
}
