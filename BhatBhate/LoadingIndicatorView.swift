//
//  LoadingIndicatorView.swift
//  Pixel
//
//  Created by AndMine on 7/1/16.
//  Copyright © 2016 AndMine. All rights reserved.
//

import Foundation
import UIKit

class LoadingIndicatorView {
    
    private static var overlayView:UIView?
    
    static func show() {
        
        hide()
        
        let parentView = UIApplication.shared.keyWindow!
        
        let overlayView = UIView(frame: CGRect(x: parentView.bounds.origin.x, y: parentView.bounds.origin.y, width: parentView.frame.width, height: parentView.frame.height))
        overlayView.alpha = 0
        overlayView.backgroundColor = UIColor.black
        
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        indicator.center = overlayView.center
        indicator.startAnimating()
        overlayView.addSubview(indicator)
        
        parentView.addSubview(overlayView)
        parentView.bringSubviewToFront(overlayView)
        
        self.overlayView = overlayView
        
        UIView.animate(withDuration: 0.5) {
            overlayView.alpha = 0.6
        }
    }
    
    static func hide() {
        
        guard let existingOverlay = overlayView else {
            return
        }
        
        existingOverlay.removeFromSuperview()
        overlayView?.removeFromSuperview()
        overlayView = nil
    }
    
}
