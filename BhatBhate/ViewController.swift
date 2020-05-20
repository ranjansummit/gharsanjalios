//
//  ViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: RootViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var dict : [String : Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //scrollView.isScrollEnabled = false
        setupScrollViewForKeyboardAppearance(scrollView: scrollView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnFacebookLogin(_ sender: UIButton) {
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self){
        result , error in
            
            if let error =  error {
                print(error.localizedDescription)
                return
            }
            
            let fbLoginResult = result!
            if fbLoginResult.grantedPermissions != nil {
                if(fbLoginResult.grantedPermissions.contains("email")){
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
            }
        
        }
        
    }

    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : Any]
                    print(self.dict)
                }
            })
        }
    }
}

