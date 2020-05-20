//
//  StarRatingView.swift
//  customer
//
//  Created by Nishan Niraula on 7/12/17.
//  Copyright © 2017 sunil. All rights reserved.
//

import UIKit

/* Class for displaying rating view. Set the class of the UIView to StarRatingView to see this control.
 
 Note: Size of the star depends upon the height of the UIView.
 */
class StarRatingView: UIView {
    
    var isEditable:Bool = true  // is star interactable
    var starRatingClicked:(()->())?
    var currentRating:Int = 3 {
        didSet {
            updateButtonRatings()
        }
    }
    
    var spacing:CGFloat = 5 {
        didSet {
            setupButtonRatings()
        }
    }
    private var maximumRating:Int = 5
    
    private var ratingButtons = [UIButton]()
    
    private lazy var fullRatingImage = #imageLiteral(resourceName: "ic_rate")
    private lazy var noRatingImage = #imageLiteral(resourceName: "ic_rate_empty")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        setupButtonRatings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clear
        setupButtonRatings()
    }
    
    private func setupButtonRatings() {
        
        // Clearing out all the ratings
        for button in ratingButtons {
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        // Creating new ratings
        for i in 0..<maximumRating {
            
            let button = UIButton()
            button.tag = i
            
            button.setImage(noRatingImage, for: UIControl.State.normal)
            
            button.setImage(fullRatingImage, for: UIControl.State.selected)
            
            // Computing its position
            let currentPositionIndex = CGFloat(i)
            let newXPosition = (currentPositionIndex * self.frame.height) + (currentPositionIndex ) * spacing
            button.frame = CGRect(x: newXPosition, y: 0, width: self.frame.height, height: self.frame.height)
            
            button.addTarget(self, action: #selector(onButtonTap(sender:)), for: UIControl.Event.touchUpInside)
            
            addSubview(button)
            
            ratingButtons.append(button)
        }
        
        updateButtonRatings()
    }
    
    private func updateButtonRatings() {
        
        for(index,button) in ratingButtons.enumerated() {
            
            // minimum rating is 1
            button.isSelected = index < currentRating
        }
    }
    
    // MARK:- Actions
    
    @objc func onButtonTap(sender:UIButton) {
        if isEditable {
            starRatingClicked?()
            self.currentRating = sender.tag + 1
        }
    }
    
    
    
    
}
