//
//  CreditPurchaseViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/9/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class CreditPurchaseViewController: RootViewController {

    @IBOutlet weak var lblCreditBalance: UILabel!
    @IBOutlet var proceedButton: UIButton!
    @IBOutlet var sellerImageView: UIImageView!
    @IBOutlet var sellerNameLabel: UILabel!
    @IBOutlet var sellerAddressLabel: UILabel!
    @IBOutlet weak var lableCreditQuantitlyValue: UILabel!
    @IBOutlet weak var lblrate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCreditBalance.text = "\( Defaults[.userCreditCount] )"
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        sellerImageView.addRoundedCorner(radius: sellerImageView.bounds.width / 2.0)
    }
    
    func setupViews() {
        lblrate.text = "at Rs. \(Defaults[.normalCredit]) (each credit) from "
        proceedButton.backgroundColor = AppTheme.Color.primaryRed
        proceedButton.setTitleColor(AppTheme.Color.white, for: .normal)
        //let sellerImage = "http://uat.bhatbhate.net/storage/logo2.jpg"
        let sellerImage = "http://bhatbhate.net/storage/logo2.jpg"
        sellerImageView.sd_setImage(with: URL(string: sellerImage), completed: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func changeCreditQuantity(_ sender: UIButton) {
        let value = lableCreditQuantitlyValue.text!
        print(value)
        switch sender.tag {
        case 0:
            lableCreditQuantitlyValue.text = "\((Int(value) ?? 0) + 1)"
        default:
            
            let newValue = (Int(value) ?? 0) - 1
            if newValue == 0 {
               
                return
            }
            lableCreditQuantitlyValue.text = newValue < 1 ? "1" : "\(newValue)"
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onProceedButtonTap(_ sender: Any) {
        if lableCreditQuantitlyValue.text == "0"{
            showAlert(title: "", message: "Invalid credit quantity.Please select atleast 1.")
            return
        }
        showLoadingIndicator()
        ApiManager.sendRequest(toApi: .getProductIDForEsewa(credit: Int(self.lableCreditQuantitlyValue.text!) ?? 10, rate: Defaults[.normalCredit]), onSuccess: {
            status , response in
            self.hideLoadingIndicator()
            switch status {
            case 200:
                if let productID = response["data"].string {
                let confirmVc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: CreditPurchaseConfirmationViewController.stringIdentifier) as! CreditPurchaseConfirmationViewController
                confirmVc.currentPurchaseType = .esewa
                confirmVc.productID = productID
                confirmVc.selectedQuantity = Int(self.lableCreditQuantitlyValue.text!) ?? 10
                self.navigationController?.pushViewController(confirmVc, animated: true)
                }else {
                self.showAlert(title: "Error", message: "Couldnot get productID.Please try again later")
                }
            default:
                self.showAlert(title: "Error", message: "Couldnot get productID.Please try again later")
            }
            
        }, onError: { error in
            self.hideLoadingIndicator()
            self.showAlert(title: "Error", message: error.localizedDescription)
            
        })
  
    }
}
