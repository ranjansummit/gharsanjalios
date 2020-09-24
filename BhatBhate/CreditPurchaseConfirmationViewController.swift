//
//  CreditPurchaseConfirmationViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 11/9/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
//import EsewaSDK
import SwiftyUserDefaults
import SwiftyJSON
class CreditPurchaseConfirmationViewController: RootViewController, CreditPurchaseConfirmationViewPresentation {
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var proceedButton: UIButton!
    @IBOutlet var proceedInfoLabel: UILabel!
    @IBOutlet var staticLabel1: UILabel!
    @IBOutlet var staticLabel2: UILabel!
    @IBOutlet var staticLabel3: UILabel!
    @IBOutlet var valueLabel1: UILabel!
    @IBOutlet var valueLabel2: UILabel!
    @IBOutlet var valueLabel3: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userAddressLabel: UILabel!
    public var currentPurchaseType: PurchaseType = .qr
    public var selectedQuantity:Int?
    public var scannedQRValues: String?
    public var afterEsewaPaymentSucceded = false
    public var productID:String!
    public var alphaCodeValues:[String:JSON]!
//    var esewaSDK: EsewaSDK!
    fileprivate var presenter: CreditPurchaseConfirmationPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CreditPurchaseConfirmationPresenter(controller: self, purchaseType: currentPurchaseType)
        if currentPurchaseType == .qr {
            presenter.processScannedValue(value: scannedQRValues)
        } else if currentPurchaseType == .alphaCode{
            presenter.processAlphaCodeValue(value: alphaCodeValues)
        }else{
            headerLabel.text = "You are purchasing \(selectedQuantity ?? 10) credit\(selectedQuantity! > 1 ? "s": "") from"
            userNameLabel.text = "AM Nepal"
            userAddressLabel.text = "Bhaisepati, Lalitpur"
            valueLabel1.text = "\(selectedQuantity!)"
            valueLabel2.text = "Rs \(Defaults[.normalCredit])"
            valueLabel3.text = "Rs \(Int(selectedQuantity!) * Defaults[.normalCredit])"
        }
    }
    
    private func getTransactionDetails(detailsValue:[String:Any]){
        if let transactionDetails = detailsValue["transactionDetails"] as? [String:String] {
            
            if let status = transactionDetails["status"] , status == "COMPLETE"{
                self.afterEsewaPaymentSucceded = true
                Defaults[.userCreditCount] = Defaults[.userCreditCount] + (self.selectedQuantity!)
                Defaults[.callGetCreditInShop] = true
                DispatchQueue.main.async {
                    self.displayPurchaseConfirmation(creditQuantity: self.selectedQuantity!, rate: Double(Defaults[.normalCredit]), amount: Double(self.selectedQuantity!) * Double(Defaults[.normalCredit]))
                }
            }else {
                afterEsewaPaymentSucceded = false
                //print("Transaction unsuccessfull")
            }
        }
    }
    
    @objc func getTransactionDetails(_ notification : Notification) {
        let detailsValue = notification.object as! [String: Any]
        //        print("**********************ESEWA RESPONSE****************************")
        //        print(detailsValue)
        if let transactionDetails = detailsValue["transactionDetails"] as? [String:String] {
            if let status = transactionDetails["status"] , status == "COMPLETE"{
                self.afterEsewaPaymentSucceded = true
                DispatchQueue.main.async {
                }
            }else {
                afterEsewaPaymentSucceded = false
            //print("Transaction unsuccessfull")
            }
        }
    }
    
    func setupViews() {
        //  self.title = "Purchase"
        switch currentPurchaseType {
        case .qr,.alphaCode:
            proceedInfoLabel.text = ""
        case .esewa:
            proceedInfoLabel.text = "Payment will be handled through E-Payment SDK"
            userNameLabel.text = "AM Nepal"
            userAddressLabel.text = "Bhaisepati, Lalitpur"
            proceedButton.setTitle("Proceed with eSewa", for: .normal)
        }
        staticLabel1.text = "Credit Quantity"
        staticLabel2.text = "Rate"
        staticLabel3.text = "Total Amount"
        let sellerImage = "http://bhatbhate.net/storage/logo2.jpg"
        userImageView.sd_setImage(with: URL(string: sellerImage), completed: nil)
        proceedButton.setTitleColor(AppTheme.Color.white, for: .normal)
        proceedButton.backgroundColor = AppTheme.Color.primaryRed
    }
    
    func setupPurchaseInformation(sellerName: String, sellerImage: String, sellerAddress: String, quantity: String, rate: String, totalAmount: String) {
        
        headerLabel.text = "You are purchasing \(quantity) credit\(quantity.count > 1 ? "s": "") from"
        
        userNameLabel.text = sellerName
        userAddressLabel.text = sellerAddress
        
        valueLabel1.text = quantity
        valueLabel2.text = "Rs " + rate
        valueLabel3.text = "Rs " + totalAmount
        
        userImageView.sd_setImage(with: URL(string: sellerImage), completed: nil)
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
        userImageView.addRoundedCorner(radius: userImageView.bounds.width / 2.0)
    }
    
    func displayError(error: AppError) {
        showAlert(title: "", message: error.localizedDescription)
    }
    
    func displayMessage(message: String) {
        showAlert(title: "", message: message)
    }
    
    func displayPurchaseConfirmation(creditQuantity: Int, rate: Double, amount: Double) {
        let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: CreditPurchaseSuccessController.stringIdentifier) as! CreditPurchaseSuccessController
        vc.creditQuantity = creditQuantity
        vc.creditRate = rate
        vc.creditAmount = amount
        vc.closeAction = { [unowned self] in
            self.navigationController?.popToRootViewController(animated: true)
            
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    override func onBackButtonTap() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func onProceedButtonTap(_ sender: Any) {
//        switch currentPurchaseType {
//        case .qr:
//            self.presenter.purchaseQRBasedCredit()
//        case .alphaCode:
//            self.presenter.purchaseAlphaCodeBasedCredit()
//        case .esewa:
//            esewaSDK = EsewaSDK(inViewController: self, environment: Constants.Esewa.environment, delegate: self)
//            let amount = valueLabel3.text?.replacingOccurrences(of: "Rs ", with: "")
////            print("merchant id",Constants.Esewa.merchantID)
////            print("merchant secret= ",Constants.Esewa.merchantSecret)
////            print("environment= ",Constants.Esewa.environment)
//            esewaSDK.initiatePayment(merchantId: Constants.Esewa.merchantID, merchantSecret: Constants.Esewa.merchantSecret, productName: "Credit Purchase", productAmount: amount!, productId: productID, callbackUrl: Constants.esewaRedirectURL)
//        }
    }
    
}
/*
 ["productName": "A.M. Nepal Pvt. Ltd.", "environment": "H", "transactionDetails": ["referenceId": "01FLJSP", "date": "Fri Jun 08 14:06:54 GMT+05:45 2018", "status": "COMPLETE"], "code": "00", "totalAmount": "500.0", "merchantName": "A.M. Nepal Pvt. Ltd.", "productID": "121528446065", "message": ["successMessage": "Your transaction has been completed.", "technicalSuccessMessage": "Your transaction has been completed."]]
 */
// this is commented as we do not need esewa right now

//extension CreditPurchaseConfirmationViewController:EsewaSDKPaymentDelegate{
//    func onEsewaSDKPaymentSuccess(info: [String : Any]) {
//      //  print("esewa response", info)
//        self.getTransactionDetails(detailsValue: info)
//    }
//
//    func onEsewaSDKPaymentError(errorDescription: String) {
//        //print("esewa failure response",errorDescription)
//        DispatchQueue.main.async {
//            self.showAlert(title: "", message: errorDescription)
//        }
//    }
//
//
//}
