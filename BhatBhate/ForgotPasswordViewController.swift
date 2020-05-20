//
//  ForgotPasswordViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 2/24/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class ForgotPasswordViewController: RootViewController {

    @IBOutlet weak var txtEmailMobile: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    var isEmail = true
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func sendConfirmationCode(_ sender: UIButton) {
    let emailAddress = txtEmailMobile.text
        var email = "0"
        var mobile = "0"
        if emailAddress?.count != 0 {
            if validateEmailAddress(emailAddress!){
                if isEmail {
                    email = emailAddress!
                }else{
                    mobile = emailAddress!
                }
                let params: [String:Any] = [
                    "email":email,
                    "mobile":mobile,
                    "client_id":Constants.clientId,
                    "client_secret":Constants.clientSecret
                ]
                print(params)
   
                    showLoadingIndicator()
                ApiManager.sendRequest(toApi: .forgotPassword(params: params), onSuccess: {
                    status , response in
                    self.hideLoadingIndicator()
                    switch status {
                    case 200:
                        let resetVC = UIStoryboard.main.instantiateViewController(withIdentifier: ResetPasswordViewController.stringIdentifier) as! ResetPasswordViewController
                        resetVC.email = email
                        resetVC.mobile = mobile
                        self.navigationController?.pushViewController(resetVC, animated: true)
                        break
                    default:
                        
                        if  let dict = response["message"].dictionary ,
                            let value = dict.values.first ,
                            let message = value.array?[0].string {
                            self.showAlert(title: "", message: message)
                            return
                        }
                        
                        if let message = response["message"].string{
                            self.showAlert(title: "Error", message: message){
                                self.txtEmailMobile.becomeFirstResponder()
                              //  self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                    print(status)
                    print(response)
                }, onError: {
                    error in
                    self.hideLoadingIndicator()
                    print(error.localizedDescription)
                    
                })
                
            }else {
                showAlert(title: "Error", message: "Please enter the valid email address or mobile number."){
                self.txtEmailMobile.becomeFirstResponder()
                }
            }
        }else{
            showAlert(title: "Error", message: "Please enter email address or mobile number"){
            self.txtEmailMobile.becomeFirstResponder()
            }
        }
        
    }
    
    
    private func validateEmailAddress(_ email: String)-> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest=NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: email){
            isEmail = true
            return true
        }else if email.count == 10{
            if  let _ = Double(email){
                isEmail = false
                return true
            }
        }
        
        return false
    }
}
