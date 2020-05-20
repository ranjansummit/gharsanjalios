//
//  SellNotificationTableViewCell.swift
//  BhatBhate
//
//  Created by sunil-71 on 12/25/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwipeCellKit
class SellNotificationTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblBikeName: UILabel!
    @IBOutlet weak var imgBike: UIImageView!
    @IBOutlet weak var btnImageClick: UIButton!
    var imageClicked: (()->())?
    var acceptClicked: (()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btnImageAction(_ sender: UIButton) {
        imageClicked?()
    }
    
    @IBAction func btnAcceptAction(_ sender: UIButton) {
        acceptClicked?()
    }
    
    func populateCell(notification:BikeNotification){
        lblDescription.text = notification.description
        lblBikeName.text = notification.vehicleName
        
    }
    
}
