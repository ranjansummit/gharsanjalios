//
//  Log.swift
//  YoursAndMine
//
//  Created by AndMine on 10/17/16.
//  Copyright © 2016 AndMine. All rights reserved.
//

import Foundation

class Log {
        
    class func start(info:String) {
        //print("---------------- \(info) ------------------- ")
    }
    
    class func clear() {
        //print("\n")
    }
    
    class func add(info:Any, fileName:String = #file, methodName:String = #function) {
      //  print("› LOG: [\(fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!).\(methodName)] : \(info)")
    }
    
    class func error(info:Any, fileName:String = #file, methodName:String = #function) {
       // print("• ERROR: [\(fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!).\(methodName)] : \(info)")
    }
    
    class func warn(info:Any, fileName:String = #file, methodName:String = #function) {
       // print("⚠ WARNING: [\(fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!).\(methodName)] : \(info)")
    }

    class func checkpoint(fileName:String = #file, methodName:String = #function) {
       // print("√ CHECKPOINT: [\(fileName.components(separatedBy: "/").last!.components(separatedBy: ".").first!).\(methodName)]")
    }
}
