//
//  PopupContainer.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/14/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit


/// Container for displaying Popup with animation
class PopupContainer {
    
    private static var overlayView: UIView?
    private static var popupView: UIView?
    
    class func show(popup: UIView,popupSize:CGSize) {
        
        let window = UIApplication.shared.keyWindow
        
        overlayView = UIView(frame: window!.bounds)
        overlayView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView!.alpha = 0
        
        window?.addSubview(overlayView!)
        
        popup.translatesAutoresizingMaskIntoConstraints = false
        overlayView!.addSubview(popup)
        
        popup.centerXAnchor.constraint(equalTo: overlayView!.centerXAnchor).isActive = true
        popup.centerYAnchor.constraint(equalTo: overlayView!.centerYAnchor, constant: 0).isActive = true
        popup.heightAnchor.constraint(equalToConstant: popupSize.height).isActive = true
        popup.widthAnchor.constraint(equalToConstant: popupSize.width).isActive = true
        
        window?.addSubview(overlayView!)
        
        self.popupView = popup
        
        popup.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIView.AnimationOptions.curveLinear, animations: {
            
            overlayView?.alpha = 1
            popup.transform = CGAffineTransform.identity
            
        }, completion: nil)
        
    }
    
    class func hide() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.overlayView?.alpha = 0
            self.popupView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
        }, completion: { (isComplete) in
            
            self.overlayView?.removeFromSuperview()
            self.popupView?.removeFromSuperview()
        })
    }

}
