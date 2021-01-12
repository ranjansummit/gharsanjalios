//
//  SellLandingTableViewCell.swift
//  BhatBhate
//
//  Created by sunil-71 on 7/17/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SDWebImage
class SellLandingTableViewCell: UITableViewCell {

    @IBOutlet weak var bikeImage: UIImageView!
    @IBOutlet weak var lblDraft: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblBikeName: UILabel!
    @IBOutlet weak var starRatingView: StarRatingView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnPublish: UIButton!
    @IBOutlet weak var labelWishlistCount: UILabel!
    
    @IBOutlet weak var viewWishlistContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var lblBuyerLeading: NSLayoutConstraint!
    
    @IBOutlet weak var heightButtonContainer: NSLayoutConstraint!
    @IBOutlet weak var lblWishlistCount: UILabel!
    @IBOutlet weak var imgWishListCount: UIImageView!
    @IBOutlet weak var lblBuyersInterested: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    //{
//        didSet{
//            labelWishlistCount.layer.cornerRadius = labelWishlistCount.frame.width/2
//            labelWishlistCount.layer.masksToBounds = true
//        }
//    }
    
    @IBOutlet weak var btnEditHeight: NSLayoutConstraint!
    @IBOutlet weak var viewWishlistInterested: UIView!
    
    var editBike : (()->())?
    var publishBike : (()->())?
    var currentBike:Bike?
    override func awakeFromNib() {
        super.awakeFromNib()
        starRatingView.isEditable = false
        starRatingView.spacing = 0
        starRatingView.layer.masksToBounds = true
        
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func btnEditTapped(_ sender: UIButton) {
        self.editBike?()
    }
    
    @IBAction func btnPublishTapped(_ sender: UIButton) {
        self.publishBike?()
    }
    
    //2d18fab9d2a161425626c85ee9ee64410e8a0653
    
    func populateCell(bike:Bike){
        
        if bike.isPublished{
            
            if bike.isSold{
                lblDraft.text = "SOLD"
                lblDraft.isHidden = false
                lblDraft.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.6)
            }else{
                lblDraft.isHidden = true
            }
        }else{
            lblDraft.text = "Draft"
            lblDraft.isHidden = false
        }
        
        //lblDraft.isHidden = bike.isPublished
        viewWishlistInterested.isHidden = !bike.isPublished
        btnEdit.isHidden = bike.isPublished
        btnPublish.isHidden = bike.isPublished
        if bike.isPublished {
            heightButtonContainer.constant = 0
            //here btnEditHeight.constant = 0
            self.layoutIfNeeded()
        }else{
           //here btnEditHeight.constant = 34
            heightButtonContainer.constant = 59
            self.layoutIfNeeded()
        }
        self.currentBike = bike
        let stringUrl = bike.imageURL?[0] ?? ""
        let imageURL = URL(string:stringUrl.formattedURL())
        bikeImage.sd_setImage(with: imageURL)
        let price = Double(bike.price ?? "0")
        lblPrice.text =  "Rs. \((price ?? 0.0).formatCurrency())"
        let bikeName = bike.brandName ?? ""
        lblBikeName.text = bikeName + " " + bike.modelName!
        starRatingView.currentRating = bike.conditionRating!
        
        lblWishlistCount.text = bike.wishCount?.description
        let buyers = bike.buyerCount ?? 0
        lblBuyersInterested.text = "\(buyers) buyer\(buyers == 1 ? "":"s") interested"
        rearrangeViews(favCount: bike.wishCount ?? 0, buyerCount: bike.buyerCount ?? 0)
    }
    
    func formatNumber(price:Double)->String?{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:price))
        return formattedNumber
    }
    
    func rearrangeViews(favCount:Int,buyerCount:Int){
        
        if favCount == 0 {
            imgWishListCount.isHidden = true
            lblWishlistCount.isHidden = true
            viewSeparator.isHidden = true
            lblBuyerLeading.constant = -15.0
        }else{
            viewWishlistInterested.backgroundColor = UIColor.from(hex: "012D6C")
            imgWishListCount.isHidden = false
            lblWishlistCount.isHidden = false
            lblBuyerLeading.constant = 10.0
        }
        if buyerCount == 0 {
            viewWishlistContainerWidth.constant = 40.0
            lblBuyersInterested.isHidden = true
            viewSeparator.isHidden = true
        }else{
            viewWishlistInterested.backgroundColor = UIColor.from(hex: "012D6C")
            viewWishlistContainerWidth.constant = 200.0
            lblBuyersInterested.isHidden = false
        }
        
        if favCount == 0  && buyerCount == 0 {
            viewWishlistInterested.backgroundColor = .clear
        }else if favCount != 0 && buyerCount != 0 {
            viewSeparator.isHidden = false
            viewWishlistInterested.backgroundColor = UIColor.from(hex: "012D6C")
        }
        layoutSubviews()
        
    }
    
}

