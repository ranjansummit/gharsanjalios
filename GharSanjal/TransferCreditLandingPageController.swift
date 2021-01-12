//
//  TransferCreditLandingPageController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/17/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftyUserDefaults

class TransferCreditLandingPageController: RootViewController {
    
    @IBOutlet var generateQRButton: UIButton!
    @IBOutlet var creditQuantityLabel: UILabel!
    @IBOutlet var creditAmtIncrementView: UIView!
    @IBOutlet var creditAmtDecrementView: UIView!
    @IBOutlet weak var lblChargeInfo: UILabel!
    
    private var creditQuantity = 1 {
        didSet {
            creditQuantityLabel.text = "\(creditQuantity)"
            lblChargeInfo.text = "You are transferring \(creditQuantity) \(creditQuantity == 1 ? "credit":"credits") at Rs. \(Defaults[.normalCredit]*creditQuantity)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        getCredit()
    }
    
    func setupViews() {
        
        creditQuantity = 1
        
        generateQRButton.addTarget(self, action: #selector(onQRGenerateButtonTap(_:)), for: .touchUpInside)
        
        creditAmtDecrementView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCreditDecrementButtonTap)))
        creditAmtIncrementView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCreditIncrementButtonTap)))
        
       // self.title = "Transfer Credits"
        
    }
    
    @objc func onQRGenerateButtonTap(_ sender: UIButton) {
        
        showLoadingIndicator()
        
        ApiManager.sendRequest(toApi: Api.Endpoint.generateQR(credit: creditQuantity), onSuccess: { (statusCode, data) in
            
            self.hideLoadingIndicator()
            
            switch statusCode {
                
            case 200:
                
                let isErrorPresent = data["error"].bool ?? true
                if !isErrorPresent {
                    
                    guard let codeId = data["data"]["id"].int,
                        let sellerName = data["data"]["seller_name"].string,
                        let creditQuantity = data["data"]["credit"].int,
                        let totalAmount = data["data"]["amount"].double,
                        let rate = data["data"]["rate"].double,
                        let alphaCode = data["data"]["code"].string,
                        let code = data["data"]["qr_code"].string else {
                            
                            self.showAlert(title: "", message: CustomError.standard.localizedDescription)
                            
                            return
                    }
                    let sellerImageUrl = data["data"]["seller_image"].string ?? ""
                    let location = data["data"]["location"].string ?? ""
                    let qrModel = CreditQRCode(codeId: codeId, sellerName: sellerName, location: location, creditQuantity: creditQuantity, totalAmount: totalAmount, rate: rate, code: code, imageUrl: sellerImageUrl)
                    
                    DispatchQueue.main.async {
                        
                        let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: QRGeneratorViewController.stringIdentifier) as! QRGeneratorViewController
                        vc.codeData = qrModel.getQRCodeRepresentation()
                        vc.creditQuantity = creditQuantity
                        vc.alphaCode = alphaCode
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                } else {
                    
                    let message = data["message"].string ?? CustomError.standard.localizedDescription
                    self.showBannerMessage(message: message)
                }

            default:
                
                let message = data["message"].string ?? CustomError.standard.localizedDescription
                self.showBannerMessage(message: message)
            }
            
        }) { (error) in
            
            self.hideLoadingIndicator()
            self.showBannerMessage(message: error.localizedDescription)
        }
    }
    
    func showBannerMessage(message:String) {
        self.showAlert(title: "", message: message)
    }
    
    @objc func onCreditIncrementButtonTap() {
        
        creditQuantity += 1
    }
    
    @objc func onCreditDecrementButtonTap() {
        
        creditQuantity = creditQuantity > 1 ? creditQuantity - 1 : 1
    }
    
    private func getCredit(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .getCredit, onSuccess: {status , response in
            self.hideLoadingIndicator()
            if status == 200 {
                if let credit = response["data"].int {
                    Defaults[.callGetCreditInShop] = false
                    Defaults[.userCreditCount] = credit
                    let tabArray = self.tabBarController?.tabBar.items
                    let tabItem = tabArray?[2]
                    tabItem?.badgeValue = "\(credit)"
//                    print("credit is changed from api", credit)
                }
            }
            
        }, onError: {error in
            
            
            
        })
        
    }
    
    
}
