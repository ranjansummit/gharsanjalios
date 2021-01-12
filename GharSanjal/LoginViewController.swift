//
//  LoginViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftyUserDefaults
import Firebase

class LoginViewController: RootViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginWithFacebookButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScrollViewForKeyboardAppearance(scrollView: scrollView)
        
        emailAddress.setCustomPlaceholder(text: "Email address")
        password.setCustomPlaceholder(text: "Password")
        
        loginButton.backgroundColor = AppTheme.Color.primaryRed
        loginWithFacebookButton.backgroundColor = AppTheme.Color.primaryBlue
    }
    
    
    
    
    @IBAction func ActionFacebookLogin(_ sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        let permisssions = ["email","public_profile"]
        fbLoginManager.logIn(withReadPermissions: permisssions, from: self, handler: {
            result , error in
            if error == nil {
                let fbLoginResult = result!
                if (result?.isCancelled)! {
                    return
                }
                if fbLoginResult.grantedPermissions.contains("email"){
                    self.getFBUserData()
                }
                
            }
            
        })
    }
    func getFBUserData(){
        print(FBSDKAccessToken.current().tokenString)
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //everything works print the user data
                    let response = result as! Dictionary<String,Any>
                    
                    /*
                     ["first_name": Sunil,
                     "email": jenil_45@hotmail.com,
                     "id": 10155232541171117,
                     "last_name": Maharjan,
                     "picture": {
                     data =     {
                     height = 200;
                     "is_silhouette" = 0;
                     url = "https://scontent.xx.fbcdn.net/v/t1.0-1/p200x200/17190583_10154788749431117_3674868288394146393_n.jpg?oh=fdf395fd2d95fa10f7f943b405713884&oe=5A92F1DD";
                     width = 200;
                     };
                     },
                     "name": Sunil Maharjan]
                     Optional(jenil_45@hotmail.com)
                     Optional(Sunil Maharjan)
                     */
                    let email = response["email"]
                    let facebookID = response["id"]!
                    let facebookName = response["name"]!
                    let facebookImage = response["picture"] as! [String:Any]
                    print(facebookImage)
                    let imageData = facebookImage["data"] as! [String:Any]
                    let image = imageData["url"] as! String
                    Defaults[.userPicURL] = image
                    Defaults[.facebookID] = facebookID
                    var parameters:[String:Any] = [
                        "facebook":1,
                        "facebook_token":facebookID,
                        "facebook_image":image,
                        "facebook_name":facebookName,
                        "client_id":Constants.clientId,
                        "client_secret":Constants.clientSecret,
                        ]
                    if email != nil {
                        parameters["email"] = email!
                    }
                    self.loginToSystem(parameters: parameters)
                }
            })
        }
    }
    
    
    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionLogin(_ sender: UIButton) {
        let email = emailAddress.text?.trimmingCharacters(in: .whitespaces)
        let pwd = password.text?.trimmingCharacters(in: .whitespaces)
        if email!.count > 0 {
            if validateEmail(email){
                if pwd!.count > 0 {
                    let parameters:[String:Any] = ["email":email!,
                                                   "password":pwd!,
                                                   "client_id":Constants.clientId,
                                                   "client_secret":Constants.clientSecret,
                                                   "facebook": 0
                    ]
                    self.loginToSystem(parameters: parameters)
                }else{
                    showAlert(title: "Error", message: "Empty password is not allowed.")
                    
                }
            }else{
                // invalid email
                showAlert(title: "Error", message: "Email address is invalid.")
                
            }
        }else{
            // empty email
            showAlert(title: "Error", message: "Empty email is not allowed.")
            
        }
    }
    private func validateEmail(_ email:String?)->Bool {
        return true
    }

    fileprivate func loginToSystem(parameters:[String:Any]){
        showLoadingIndicator()
        ApiManager.sendRequest(toApi: .getToken(params: parameters), onSuccess: {
            statusCode , response in
            self.hideLoadingIndicator()
            print(statusCode)
            print(response)
            
            if statusCode == 200 {
                let accessToken =  response["data"]["access_token"].string
                let refreshToken = response["data"]["refresh_token"].string
                
                Defaults[.accessToken] = accessToken
                Defaults[.refreshToken] = refreshToken
                Defaults[.isLoggedIn] = true
                let email = response["data"]["email"].string
                let mobile = response["data"]["mobile"].string
                let normalCredit = response["data"]["normal_credit"].int
                let promotionMode = response["data"]["promotion_mode"].int ?? 1
                if let profileImage = response["data"]["image"].string, profileImage != ""{
                    Defaults[.userPicURL] = profileImage
                }
                let previewMode = response["data"]["onreview"].int ?? 0
                Defaults[.preview] = false//previewMode == 1
                Defaults[.promotionMode] = promotionMode == 1
                Defaults[.normalCredit] = normalCredit ?? 500
                let discountedCredit = response["data"]["discounted_credit"].int
                Defaults[.discountedCredit] = discountedCredit ?? 400
                
                Defaults[.userName] = response["data"]["name"].string
                Defaults[.userEmail] = email//response["data"]["email"].string
                Defaults[.userMobile] = mobile//response["data"]["mobile"].string
                Defaults[.userId] = response["data"]["id"].int
                Defaults[.userCreditCount] = response["data"]["available_credit"].int ?? 0
                Defaults[.userLoggedInDate] = response["data"]["updated_at"].string ?? ""
                Defaults[.reloadSellLsting] = true
                Defaults[.reloadBuyListing] = true
                if let fcmToken = Messaging.messaging().fcmToken {
                    NotificationManager.updateFCMTokenIfNeeded(obtainedToken: fcmToken)
                }

                if email == nil || mobile == nil {
                    Defaults[.noEmailOrMobile] = true
                }
                self.dismiss(animated: true){
                    print("log out called")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let window = appDelegate.window
                    let tabBarViewController = UIStoryboard.main.instantiateViewController(withIdentifier: TabBarViewController.stringIdentifier) as! UITabBarController
                    window?.rootViewController = tabBarViewController
                }
                
            }else if statusCode == 404 {
//
                if let errorCode = response["err_code"].int {
                    
                    switch errorCode {
                    case 101:
                        let email = response["data"]["email"].string
                        let mobile = response["data"]["mobile"].string
                        let smsVerificationVC = UIStoryboard.main.instantiateViewController(withIdentifier: SmsVerificationViewController.stringIdentifier) as! SmsVerificationViewController
                        smsVerificationVC.mobile = mobile
                        smsVerificationVC.email = email
                        self.navigationController?.pushViewController(smsVerificationVC, animated: true)
                    case 106:
                        if let message = response["message"].string{
                            self.showAlert(title: "Error", message: message)
                        }
                    case 105:
                        if  let dict = response["message"].dictionary ,
                            let value = dict.values.first ,
                            let message = value.array?[0].string {
                            self.showAlert(title: "", message: message)
                            return
                        }
                    
                    default :
                        let message = response["message"].string
                        self.showAlert(title: "Error", message: message ??  "Something went wrong. Please try again later.")
                    }
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
            self.showAlert(title: "", message: error.localizedDescription)
            
        })
        
    }
    
}
