//
//  BikeNotificationCell.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwipeCellKit

class BikeNotificationCell: SwipeTableViewCell {

    @IBOutlet weak var labelNotificationType: UILabel!
    @IBOutlet var bikeImageView: UIImageView!
    @IBOutlet var notificationTitleLabel: UILabel!
    @IBOutlet var notificationDescriptionLabel: UILabel!
    @IBOutlet var creditAmountLabel: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    
    @IBOutlet weak var heightTitleLabel: NSLayoutConstraint!
    var imageTapAction:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.bikeImageView.contentMode = .scaleAspectFill
        self.bikeImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onImageButtonTap(_ sender: Any) {
        
        imageTapAction?()
    }
}
