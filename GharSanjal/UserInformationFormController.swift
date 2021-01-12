//
//  UserInformationFormController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/19/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class UserInformationFormController: RootViewController {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var mobileNumberField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet weak var mobileContainer: UIView!
    
   public var userEmail: String?       // User existing email if available
     public var userMobile: String?      // User existing mobile if available
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        
        addDoneButtonOnKeyboard()
        emailField.text = userEmail
        emailField.isEnabled = (userEmail == "" || userEmail == nil)
        mobileContainer.addRoundedCorner(radius: 5.0)
        mobileNumberField.text = userMobile
        mobileNumberField.isEnabled = (userMobile == "" || userMobile == nil)
        mobileNumberField.setLeftPaddingPoints(5.0)
        mobileNumberField.setBorderToLeft()
        
        self.title = "Missing Information"
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onViewTap)))
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(AppTheme.Color.white, for: .normal)
        submitButton.backgroundColor = AppTheme.Color.primaryRed
        submitButton.addTarget(self, action: #selector(onSubmitButtonTap), for: .touchUpInside)
        
        emailField.placeholder = "Email"
        mobileNumberField.placeholder = "Mobile No."
        
        // If user has provided email address already, filling out that information
        // and disabling email field
        if let email = userEmail, !email.isEmpty {
            emailField.text = email
            emailField.isEnabled = false
        }
        
        // If user has provided mobile number already, filling out that information
        // and disabling mobile field
        if let mobile = userMobile, !mobile.isEmpty {
            mobileNumberField.text = "+977 " + mobile
            mobileNumberField.isEnabled = false
        }
    }

    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func onViewTap() {
        self.emailField.resignFirstResponder()
        self.mobileNumberField.resignFirstResponder()
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
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        mobileNumberField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    @objc func onSubmitButtonTap() {
        userEmail = emailField.text
        userMobile = mobileNumberField.text
        if let email = userEmail, let mobileNumber = userMobile, !email.isEmpty, !mobileNumber.isEmpty {
            if validateEmail(email){
                if validateMobile(mobileNumber){
                    self.showLoadingIndicator()
                    ApiManager.sendRequest(toApi: Api.Endpoint.sendActivationCode(email: email, mobile: mobileNumber), onSuccess: { (statusCode, data) in
                        
                        self.hideLoadingIndicator()
                        
                        switch statusCode {
                            
                        case 200:
                            
                            let isErrorPresent = data["error"].bool ?? true
                            
                            if !isErrorPresent {
                                
                                let message = data["message"].string ?? "Verification code has been sent to your mobile number"
                                self.showAlert(title: "", message: message, alertAction: {
                                    let verificationVc = UIStoryboard.main.instantiateViewController(withIdentifier: SmsVerificationViewController.stringIdentifier) as! SmsVerificationViewController
                                    verificationVc.email = email
                                    verificationVc.mobile = mobileNumber
                                    verificationVc.fromMissingVC = true
                                    self.navigationController?.pushViewController(verificationVc, animated: true)
                                })
                                
                            } else {
                                
                                let message = data["message"].string ?? CustomError.standard.localizedDescription
                                self.showAlert(title: "", message: message)
                            }
                            
                        default:
                            
                            if  let dict = data["message"].dictionary ,
                                let value = dict.values.first ,
                                let message = value.array?[0].string {
                              self.showAlert(title: "Error", message: message)
                                return
                            }
                            
                            let message = data["message"].string ?? CustomError.standard.localizedDescription
                            self.showAlert(title: "", message: message)
                            
                            
                        }
                        
                    }, onError: { (error) in
                        
                        self.hideLoadingIndicator()
                        self.showAlert(title: "", message: error.localizedDescription)
                        
                    })
                }else{
                    showAlert(title: "Error", message: "The mobile number should be 10 digits")
                }
            }else{
                showAlert(title: "Error", message: "Invalid Email address fromat")
            }
            

        } else {
                self.hideLoadingIndicator()
            self.showAlert(title: "", message: "Fill all the missing information")
        }
    }
}
