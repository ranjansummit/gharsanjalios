//
//  CreditPurchaseSuccessController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/10/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit

class CreditPurchaseSuccessController: RootViewController {

    @IBOutlet var closeImageView: UIImageView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var footerLabel: UILabel!
    
    @IBOutlet var creditQuantityLabel: UILabel!
    @IBOutlet var staticCreditsLabel: UILabel!
    
    @IBOutlet var infoTitleLabel: UILabel!
    @IBOutlet var infoSubtitleLabel: UILabel!
    
    @IBOutlet var staticRateLabel: UILabel!
    @IBOutlet var staticTotalAmountLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var totalAmountLabel: UILabel!
    
    public var creditQuantity: Int?
    public var creditRate: Double?
    public var creditAmount: Double?
    public var closeAction: (()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    func setupViews() {
        
        guard let quantity = creditQuantity, let rate = creditRate, let amount = creditAmount else { return }
        
        self.view.backgroundColor = AppTheme.Color.primaryBlue
        staticRateLabel.textColor = UIColor.white
        staticTotalAmountLabel.textColor = UIColor.white
        rateLabel.textColor = UIColor.white
        totalAmountLabel.textColor = UIColor.white
        
        infoTitleLabel.textColor = UIColor.white
        infoSubtitleLabel.textColor = UIColor.white
        
        creditQuantityLabel.textColor = UIColor.white
        staticCreditsLabel.textColor = UIColor.white
        
        footerLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        
        staticRateLabel.text = "Rate"
        staticTotalAmountLabel.text = "Total Amount"
        
        infoSubtitleLabel.text = "You have purchased \(quantity) credit\(quantity > 1 ? "s":"")"
        creditQuantityLabel.text = "\(quantity)"
        staticCreditsLabel.text = "credit\(quantity > 1 ? "s": "")"
        rateLabel.text = "Rs. \(Int(rate))"
        totalAmountLabel.text = "Rs. \(Int(amount))"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCloseButtonTap(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        self.closeAction?()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
