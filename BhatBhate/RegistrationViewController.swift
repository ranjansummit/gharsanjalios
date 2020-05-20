//
//  RegistrationViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 11/27/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class RegistrationViewController: RootViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBOutlet weak var textFullName: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textMobile: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textConfirmPassword: UITextField!
    @IBOutlet weak var mobileContainer: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

    }

    
    private func setupViews(){
        mobileContainer.addRoundedCorner(radius: 5.0)
        setupScrollViewForKeyboardAppearance(scrollView: scrollView)
        textFullName.setCustomPlaceholder(text: "Full Name")
        textEmail.setCustomPlaceholder(text: "Email Address")
        textMobile.setCustomPlaceholder(text: "Mobile Number")
        textPassword.setCustomPlaceholder(text: "Password")
        textConfirmPassword.setCustomPlaceholder(text: "Confirm Password")
        textMobile.setLeftPaddingPoints(5.0)
        textMobile.setBorderToLeft()
        btnRegister.backgroundColor = AppTheme.Color.primaryRed
        btnRegister.setTitle("Register", for: .normal)
    }
    
    @IBAction func actionRegister(_ sender: UIButton) {
        let fullName = textFullName.text
        let email = textEmail.text
        let password = textPassword.text
        let confirmPassword = textConfirmPassword.text
        let mobile = textMobile.text
        
        if fullName!.count > 0 {
            if email!.count > 0 {
                if validateEmail(email!){
                    if mobile!.count > 0 {
                        if validateMobile(mobile!){
                            if password!.count > 5 {
                                if password! == confirmPassword!{
                                    let parameters:[String:Any] = ["name":fullName!,
                                                      "email":email!,
                                                      "mobile":mobile!,
                                                      "password":password!,
                                                      "password_confirmation":confirmPassword!,
                                                      "client_id":Constants.clientId,
                                                      "client_secret":Constants.clientSecret
                                        ]
                                    showLoadingIndicator()
                                   ApiManager.sendRequest(toApi: .registerUser(params: parameters), onSuccess: {
                                    statusCode , response in
                                    self.hideLoadingIndicator()
                                    if statusCode == 200 {
                                        let smsVC = UIStoryboard.main.instantiateViewController(withIdentifier: SmsVerificationViewController.stringIdentifier) as! SmsVerificationViewController
                                        smsVC.email = self.textEmail.text
                                        smsVC.mobile = self.textMobile.text
                                        self.navigationController?.pushViewController(smsVC, animated: true)
                                    }else{
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

                                }else{
                                    // password and confirm password do not match
                                    showAlert(title: "Error", message: "Password and confirm password do not match.")
                                }
                            }else{
                                // empty password field
                                showAlert(title: "Error", message: "Password should be atleast 6 characters in length.")
                            }
                        }else{
                            // invalid mobile number
                            showAlert(title: "Error", message: "Mobile number is invalid.")
                        }
                    }else{
                        // empty moble number
                        showAlert(title: "Error", message: "Mobile number field is empty.")
                    }
                }else{
                    // Invalid email address format
                    showAlert(title: "Error", message: "Email address is invalid.")
                }
            }else{
                // email empty
                showAlert(title: "Error", message: "Email address field is empty.")
            }
        }else{
            // empty full name
            showAlert(title: "Error", message: "Full name field is empty.")
        }

    }
    
    private func validateEmail(_ email: String)-> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest=NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluate(with: email){
            return true
        }
        
        return false
    }
    
    private func validateMobile(_ mobile:String)->Bool{
        if mobile.count == 10 {
            return true
        }
        return false
    }
}
