//
//  PurchaseCreditPopup.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit

class PurchaseCreditPopup: UIView {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var closeImageView: UIImageView!
    @IBOutlet var requestButton: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var creditQuantityLabel: UILabel!
    
    @IBOutlet var plusContainerView: UIView!
    @IBOutlet var minusContainerView: UIView!
    
    public var requestButtonAction: (()->())?
    public var closeButtonAction: (()->())?
    
    public let defaultSize = CGSize(width: 320, height: 328)
    public var creditQuantity:Int = 1 {
        didSet {
            self.creditQuantityLabel.text = "\(creditQuantity)"
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupXib()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.frame = bounds
    }
    
    func setupXib() {
        
        self.containerView = Bundle.main.loadNibNamed(PurchaseCreditPopup.stringIdentifier, owner: self, options: nil)![0] as! UIView
        
        self.containerView.frame = bounds
        self.containerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.containerView.backgroundColor = AppTheme.Color.backgroundBlue
        
        addSubview(self.containerView)
        
        self.closeButton.addTarget(self, action: #selector(onCloseButtonTap), for: .touchUpInside)
        
        self.requestButton.setTitleColor(AppTheme.Color.white, for: .normal)
        self.requestButton.backgroundColor = AppTheme.Color.primaryRed
        self.requestButton.setTitle("REQUEST", for: .normal)
        
        plusContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPlusViewTapped)))
        minusContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMinusViewTapped)))
        requestButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRequestButtonTap)))
    }
    
    @objc func onRequestButtonTap() {
        requestButtonAction?()
    }
    
    @objc func onPlusViewTapped() {
        creditQuantity += 1
    }
    
    @objc func onMinusViewTapped() {
        creditQuantity = creditQuantity == 1 ? 1 : creditQuantity - 1
    }
    
    @objc func onCloseButtonTap() {
        closeButtonAction?()
    }
    
    func setupDefaultConfiguration() {
        
        headerView.backgroundColor = AppTheme.Color.primaryBlue
        headerLabel.textColor = AppTheme.Color.white
        headerLabel.text = "Contact Seller"
        
        requestButton.backgroundColor = AppTheme.Color.primaryRed
        
        creditQuantity = 1
    }
    
}


