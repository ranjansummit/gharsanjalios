//
//  PinVerificationViewController.swift
//  customer
//
//  Created by sunil maharjan on 10/15/17.
//  Copyright © 2017 sunil. All rights reserved.
//

import UIKit

class PinVerificationViewController: RootViewController {
    
    @IBOutlet weak var lblWehaveSent: UILabel!
    @IBOutlet weak var lblEnterVerificationCode: UILabel!
    @IBOutlet weak var textPin1: UITextField!
    @IBOutlet weak var textPin2: UITextField!
    @IBOutlet weak var textPin4: UITextField!
    @IBOutlet weak var textPin3: UITextField!
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        
    }
    
    private func setupViews(){
        
        self.view.semanticContentAttribute = .forceLeftToRight
        
        textPin1.delegate = self
        textPin2.delegate = self
        textPin3.delegate = self
        textPin4.delegate = self
        
        
        textPin1.addBorder()
        textPin2.addBorder()
        textPin3.addBorder()
        textPin4.addBorder()
        
       // btnResend.setTitle(AppStrings.pinVerificationResend.localized(), for: .normal)
        //btnResend.setTitleColor(AppTheme.baseColor, for: .normal)
        
        //btnSubmit.setTitle(AppStrings.pinVerificationSubmit.localized(), for: .normal)
        
        //lblWehaveSent.text = AppStrings.pinverificationWeHaveSent.localized()
        //lblWehaveSent.textColor = .white
        
       // lblEnterVerificationCode.text = AppStrings.pinVerificationEnterVerification.localized()
        //lblEnterVerificationCode.textColor = AppTheme.baseColor
        
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        
        if textPin1.text?.count != 0 && textPin2.text?.count != 0 && textPin3.text?.count != 0 && textPin4.text?.count != 0 {
            let pinCode = textPin1.text! + textPin2.text! + textPin3.text! + textPin4.text!
            showLoadingIndicator()
            print(pinCode)
           ApiManager.sendRequest(toApi: .purchaseViaCode(code: pinCode), onSuccess: {
          [unowned self]  status , response in
            self.hideLoadingIndicator()
            if let error = response["error"].bool , error {
                self.showAlert(title: "", message: response["message"].string ?? "Error Occurred.")
                return
            }
            print(status)
            print(response)
            guard let data = response["data"].dictionary else {
                self.showAlert(title: "", message: "Could not verify code")
                return
            }
            let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: CreditPurchaseConfirmationViewController.stringIdentifier) as! CreditPurchaseConfirmationViewController
                vc.alphaCodeValues = data
            vc.currentPurchaseType = .alphaCode
            self.navigationController?.pushViewController(vc, animated: true)
           }, onError: {appError  in
            
           })
                
/*
             {
             "data" : {
             "qr_code" : "eyJpdiI6IjZWbGFZK281RjNvUjFlVkxUR0k4R0E9PSIsInZhbHVlIjoiMm9GY1c1RExldkwxeHp3NjFuNExHdHhmbFNibFwvVU83TlNEVDVudEYrZUpQeDVkMjZzUm94SXdzRSs5TGVHM0pRUEdEUFNoanRxelRxYVF5WVwvNEhIY2FMNTlibzFpa2xCZ2xCOUl0czVIND0iLCJtYWMiOiJiMGY2MzVjMjIwMzVlYjhmOTVhYmQ3OGI1YmVhMTkxNDlhMWY5MTBmMjBjZGVhOWYyMzZjYWY4ZTU2MjQwY2ZmIn0=",
             "updated_at" : "2018-05-23 10:11:34",
             "credit" : 2,
             "amount" : 1000,
             "seller_name" : "kesha tester",
             "rate" : 500,
             "latitude" : 27.65077131,
             "scanned_status" : "0",
             "location" : null,
             "id" : 205,
             "expires_at" : "2018-05-23 11:51:34",
             "created_at" : "2018-05-23 10:11:34",
             "seller_image" : "http:\/\/uat.bhatbhate.net\/storage\/user_images\/jYTmgwefm5hDdESzFxGQW0cH4PdNk6GxjQiNIZGN.jpeg",
             "user_id" : 8,
             "longitude" : 85.303956700000001
             },
             "error" : false
             }
             */
            
        }else {
            showAlert(title: "", message: "Please enter four digit case sensitive alphanumeric code.")
          //  ToastManager().showToast(type: .failure, message: AppStrings.pinVerificationInvalid.localized())
        }
        
        
        
    }
    
    
}

extension PinVerificationViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.count)! < 1 && string.count > 0 {
            if(textField == textPin1){
                textPin2.becomeFirstResponder()
            }
            if(textField == textPin2){
                textPin3.becomeFirstResponder()
            }
            if(textField == textPin3){
                textPin4.becomeFirstResponder()
            }
            
            textField.text = string
            return false
            
        }else if ((textField.text?.count)! >= 1  && string.characters.count == 0){
            // on deleting value from Textfield
            if(textField == textPin2){
                textPin1.becomeFirstResponder()
            }
            if(textField == textPin3){
                textPin2.becomeFirstResponder()
            }
            if(textField == textPin4 ) {
                textPin3.becomeFirstResponder()
            }
            textField.text = ""
            return false
        }else if ((textField.text?.count)! >= 1  ){
            textField.text = string
            return false
        }
        return true
    }
    
}
