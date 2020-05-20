//
//  TransactionHistoryTableViewCell.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/12/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwipeCellKit
class TransactionHistoryTableViewCell:SwipeTableViewCell  {
    
    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var noOfPurchaseLabel: UILabel!
    @IBOutlet var voucherIdLabel: UILabel!
    @IBOutlet var transactionDateLabel: UILabel!
    
    @IBOutlet weak var labelStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
