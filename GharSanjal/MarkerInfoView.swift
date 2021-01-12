//
//  MarkerInfoView.swift
//  BhatBhate
//
//  Created by sunil-71 on 6/21/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit

class MarkerInfoView: UIView {

    @IBOutlet private weak var buyerMobile: UILabel!
    @IBOutlet private weak var buyerName: UILabel!
    var contentView: UIView!
   let nibName = MarkerInfoView.stringIdentifier
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        self.contentView.layer.masksToBounds = true
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 10
    }
    
    func setupViews()  {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName, bundle: bundle)
        self.contentView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(contentView)
        
        contentView.center = self.center
        contentView.autoresizingMask = []
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
    }
    
   // class func instanceFromNib()->MarkerInfoView{
//        return UINib(nibName: MarkerInfoView.stringIdentifier, bundle: nil).instantiate(withOwner: self, options: nil).first as! MarkerInfoView
//    }
    
    public func set(name text:String){
        self.buyerName.text = text
    }
    
    public func set(mobile text:String){
        self.buyerMobile.text = text
    }
    
}
