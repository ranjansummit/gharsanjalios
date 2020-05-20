//
//  SmsVerificationViewController.swift
//  
//
//  Created by sunil-71 on 11/27/17.
//

import UIKit
import SwiftyUserDefaults
class SmsVerificationViewController: RootViewController {
    
    @IBOutlet weak var textVerificationCode: UITextField!
    
    public var mobile:String?
    public var email:String?
    public var fromMissingVC = false
    @IBOutlet weak var lblMobileNumber: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = mobile, let _ = email else {
        //    print("no email address")
            return
        }
        
        lblMobileNumber.text = "and email address"//mobile
        
    }
    
    @IBAction func actionVeryfy(_ sender: Any) {
        let code = textVerificationCode.text?.trimmingCharacters(in: .whitespaces)
        if code!.count == 6 {
            if fromMissingVC {
                VerifyMobileNumber(code: code)
            }else{
                verifyUser(code: code)
            }
        }else{
            self.showAlert(title: "Error", message: "Invalid verification code.")
            textVerificationCode.becomeFirstResponder()
        }
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func VerifyMobileNumber(code:String?){
        guard let mobileNo = self.mobile else {
            showAlert(title: "", message: "Mobile number is required")
            return
        }
        let parameters:[String:Any] = [
            "enable_code":code!,
            "mobile":mobileNo
        ]
        LoadingIndicatorView.show()
        ApiManager.sendRequest(toApi: .verifyMobile(params: parameters), onSuccess: {
            [unowned self] statusCode , response in
            self.hideLoadingIndicator()
            if statusCode == 200 {
                if let error = response["error"].bool , !error {
                    let message = response["message"].string ?? "Verified Successfully"
                    let mobile = response["data"]["mobile"].string!
                    let email = response["data"]["email"].string!
                    Defaults[.userMobile] = mobile
                    Defaults[.userEmail] = email
                    self.showAlert(title: "", message: message){
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }else {
                if let message = response["message"].string {
                    self.showAlert(title: "Error", message: message)
                    return
                }
                if  let dict = response["message"].dictionary ,
                    let value = dict.values.first ,
                    let message = value.array?[0].string {
                    self.showAlert(title: "", message: message)
                    return
                }
            }
            
            }, onError: {error in
                self.hideLoadingIndicator()
                self.showAlert(title: "Error", message: error.localizedDescription)
        })
    }
    private func verifyUser(code:String?){
        let parameters:[String:Any] = ["email":self.email!,
                                       "mobile":self.mobile!,
                                       "enable_code":code!,
                                       "client_id":Constants.clientId,
                                       "client_secret":Constants.clientSecret]
        LoadingIndicatorView.show()
        ApiManager.sendRequest(toApi: .enableUser(params: parameters), onSuccess: {
            [unowned self] statusCode , response in
            LoadingIndicatorView.hide()
            //print(statusCode)
            //print(response)
            if statusCode == 200 {
                if let error = response["error"].bool , !error{
                    
                    
                    self.showAlert(title: "", message: "Your account is activated. Please login again.", alertAction: {
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    return
                }
            }else {
                if let message = response["message"].string {
                    self.showAlert(title: "", message: message)
                    return
                }
                
                if  let dict = response["message"].dictionary ,
                    let value = dict.values.first ,
                    let message = value.array?[0].string {
                    self.showAlert(title: "", message: message)
                    return
                }
            }
            }, onError: {
                error in
                self.hideLoadingIndicator()
                self.showAlert(title: "Error", message: error.localizedDescription)
        })
    }
    
    @IBAction func resendVerification(_ sender: UIButton) {
        guard let mobile = self.mobile , let email = self.email else {
            return
        }
        let params = ["mobile":mobile,
                      "email":email]
        showLoadingIndicator()
        ApiManager.sendRequest(toApi: .resendCode(params: params), onSuccess: {
            status , response in
            self.hideLoadingIndicator()
           // print(status)
            //print(response)
            switch status {
            case 200:
                if let error = response["error"].bool, !error {
                    let message = response["message"].string!
                    self.showAlert(title: "Success", message: message)
                    
                }
                return
            default:
                if  let dict = response["message"].dictionary ,
                    let value = dict.values.first ,
                    let message = value.array?[0].string {
                    self.showAlert(title: "", message: message)
                    return
                }
                if let message = response["message"].string{
                    self.showAlert(title: "", message: message)
                }
            }
        }, onError: {
            appError in
            self.hideLoadingIndicator()
            
        })
    }
    
    
}
