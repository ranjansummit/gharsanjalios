//
//  BuyListingCell.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit

class BuyListingCell: UITableViewCell {

    @IBOutlet var bikeImageView: UIImageView!
    
    @IBOutlet weak var lblSold: UILabel!
    @IBOutlet var bikeNameLabel: UILabel!
    @IBOutlet var bikeConditionLabel: UILabel!
    @IBOutlet var bikePriceLabel: UILabel!
    
    @IBOutlet var bikeConditionView: StarRatingView!
    
    @IBOutlet var wishlistImageView: UIImageView!
    @IBOutlet var addToWishlistButton: UIButton!
    
    @IBOutlet weak var lblBuyersInterested: UILabel!
    @IBOutlet weak var viewWishContainer: UIView!
    @IBOutlet weak var imgWishListCount: UIImageView!
    @IBOutlet weak var lblWishlistCount: UILabel!
    public var wishlistButtonAction: (()->())?
    
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var lblBuyerLeading: NSLayoutConstraint!
    @IBOutlet weak var favWishlistContainerWidth: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bikeConditionView.isEditable = false
        bikeConditionView.spacing = 0
        bikeImageView.layer.masksToBounds = true
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onAddToWishlistButtonTap(_ sender: UIButton) {
        
        wishlistButtonAction?()
    }
    
    func rearrangeViews(favCount:Int,buyerCount:Int){
      
        if favCount == 0 {
            imgWishListCount.isHidden = true
            lblWishlistCount.isHidden = true
            viewSeparator.isHidden = true
            lblBuyerLeading.constant = -15.0
        }else{
            viewWishContainer.backgroundColor = UIColor.from(hex: "012D6C")
            imgWishListCount.isHidden = false
            lblWishlistCount.isHidden = false
            lblBuyerLeading.constant = 10.0
        }
        if buyerCount == 0 {
            favWishlistContainerWidth.constant = 40.0
            lblBuyersInterested.isHidden = true
            viewSeparator.isHidden = true
        }else{
            viewWishContainer.backgroundColor = UIColor.from(hex: "012D6C")
            favWishlistContainerWidth.constant = 200.0
            lblBuyersInterested.isHidden = false
        }
        
        if favCount == 0  && buyerCount == 0 {
            viewWishContainer.backgroundColor = .clear
        }else if favCount != 0 && buyerCount != 0 {
            viewSeparator.isHidden = false
            viewWishContainer.backgroundColor = UIColor.from(hex: "012D6C")
        }
            layoutSubviews()
        
    }

}
