//
//  AnimationChain.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/14/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit

struct Animation {
    
    fileprivate let animation: (()->())
    fileprivate let duration: TimeInterval
    fileprivate let completionHandler: (()->()) = { }
    
    func onCompletion( ) {
        
    }
    
    func execute() {
        UIView.animate(withDuration: duration, animations: animation) { (isComplete) in
            
            if isComplete {
                
            }
        }
    }
    
}

class AnimationChain {
    
    private var animationQueue = [Animation]()
    
    
    /*
     let chain = AnimationChain()
     chain.add(Animation)
     chain.add(Animation)
     chain.add(Animation)
     chain.execute()
     */
    
    func add(animation: Animation) {
        animationQueue.append(animation)
    }
    
    
    func startExecution() {
        
    }
    
}
