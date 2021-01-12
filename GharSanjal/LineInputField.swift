//
//  LineInputField.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/9/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit

class LineInputField: UITextField {
    
    
    var leftPadding:CGFloat = 30
    var rightPadding:CGFloat = 30
    var topPadding:CGFloat = 10
    var bottomPadding:CGFloat = 10
    
    var borderThickness:CGFloat = 1
    
    var borderStrokeColor:CGColor = AppTheme.Color.primaryBlue.cgColor
    var borderErrorColor:CGColor = AppTheme.Color.primaryRed.cgColor
    
    private var isErrorShown = false
    private var borderLayer:CAShapeLayer!
    
    //MARK:- Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        borderLayer.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.height - borderThickness, width: self.bounds.width, height: self.borderThickness)
    }
    
    
    //MARK:- Padding Setup
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return bounds.inset(by: UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding))
    }
    
    private func setupView() {
        
        self.borderStyle = .none
        self.textColor = UIColor.white
        
        borderLayer = CAShapeLayer()
        borderLayer.backgroundColor = borderStrokeColor
        self.layer.addSublayer(borderLayer)
    }
    
    // MARK:- Placeholder
    
    func setPlaceholder(text:String) {
        
        self.attributedPlaceholder  = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.6)])
    }
    
    // MARK:- Error Helpers
    
    func showError() {
        
        borderLayer.backgroundColor = borderErrorColor
        isErrorShown = true
    }
    
    func hideError() {
        
        borderLayer.backgroundColor = borderStrokeColor
        isErrorShown = false
    }
    
    
}

