//
//  ResetPasswordViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 2/24/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit

class ResetPasswordViewController: RootViewController {

    @IBOutlet weak var txtResetCode: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    var email:String?
    var mobile:String?
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.title = "Reset Password"
    }
    
    @IBAction func btnResetPasswordClicked(_ sender: UIButton) {
        let resetCode = txtResetCode.text!
        let password = txtPassword.text!
        let confirmPassword = txtConfirmPassword.text!
        
        if resetCode.count > 0 {
            if password.count > 5 {
                if password == confirmPassword {
                    let params : [String:Any] = [
                        "email":email!,
                        "mobile":mobile!,
                        "reset_code":resetCode,
                        "password":password,
                        "password_confirmation":confirmPassword,
                        "client_id":Constants.clientId,
                        "client_secret":Constants.clientSecret
                    ]
                    
                    showLoadingIndicator()
                    
                    ApiManager.sendRequest(toApi: .changePassword(params: params), onSuccess: {
                        status , response in
                        self.hideLoadingIndicator()
                        let message = response["message"].string
                        if let status = response["error"].bool , !status {
                            self.showAlert(title: "", message: "Your password changed successfully"){
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                            return
                        }
                        self.showAlert(title: "Error", message: message ?? "Something went wrong.Please try again")
                    }, onError: {
                        error in
                        self.hideLoadingIndicator()
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    })
                }else {
                    showAlert(title: "Error", message: "Password and confirm password do not match")
                }
            }else{
                showAlert(title: "Error", message: "Password should be at least 6 characters in length")
            }
        }else{
            showAlert(title: "", message: "Invalid reset code.")
        }
    }
    
}
