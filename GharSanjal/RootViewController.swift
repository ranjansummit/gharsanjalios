//
//  RootViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
import SwiftyUserDefaults
class RootViewController: UIViewController, NetworkRequestPresentable {

    private var adjustableScrollView:UIScrollView?
    private var isKeyboardNotificationAvailable = false
    var remoteConfig: RemoteConfig!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = AppTheme.Color.backgroundBlue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        configreRemoteConfig()
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = AppTheme.Color.primaryBlue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isOpaque = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(onBackButtonTap))
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
       self.navigationController?.title = ""
        // Change the backbutton icon
        let backImage = #imageLiteral(resourceName: "ic_nav_back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
        
    }
    
    @objc func onBackButtonTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configreRemoteConfig()
        setupKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardNotification()
    }
    
    
    /// Displays alert in **Main** thread.
    ///
    /// - Parameters:
    ///   - title: title for the alert
    ///   - message: description message
    ///   - alertAction: action to be executed on action button press
    func showAlert(title:String,message:String,alertAction:(()->())? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let defaultAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) { (action) in
            
            alertAction?()
        }
        alertController.addAction(defaultAction)
        
       // DispatchQueue.main.async {
            
            self.present(alertController, animated: true, completion: nil)
        //}
    }
    
    func showYesNoAlert(title:String,message:String,yesTitle:String,noTitle:String,alertAction:((_ yesNo:Bool)->())? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: yesTitle, style: UIAlertAction.Style.default) { (action) in
            
            alertAction?(true)
        }
        
        let noAction = UIAlertAction(title: noTitle, style: UIAlertAction.Style.default) { (action) in
            alertAction?(false)
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        
        // DispatchQueue.main.async {
        
        self.present(alertController, animated: true, completion: nil)
        //}
    }
    
    
    func showYesNoAlert(title:String,message:String,alertAction:((_ yesNo:Bool)->())? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (action) in
            
            alertAction?(true)
        }
        
        let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) { (action) in
            alertAction?(false)
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        
        // DispatchQueue.main.async {
        
        self.present(alertController, animated: true, completion: nil)
        //}
    }
    /*-----------------------------------
     MARK:- Keyboard Notification Helper
     -----------------------------------*/
    
    func setupScrollViewForKeyboardAppearance(scrollView:UIScrollView) {
        
        self.adjustableScrollView = scrollView
        self.isKeyboardNotificationAvailable = true
    }
    
    final private func setupKeyboardNotification() {
        if isKeyboardNotificationAvailable {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    final private func removeKeyboardNotification() {
        
        if isKeyboardNotificationAvailable {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    @objc final func keyboardWillShow(_ notification:Notification) {
        
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = keyboardSize.height
        
        guard let scrollView = adjustableScrollView else { return }
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc final func keyboardWillHide(_ notification:Notification) {
        
        guard let scrollView = adjustableScrollView else { return }
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    @objc final func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
    func showLoginScreen(){
        let navController = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        self.tabBarController?.present(navController, animated: true, completion: nil)
        
    }
    
}

extension RootViewController:UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view is UIButton){
            return false
        }
        return true
    }
    
}
extension RootViewController {
    func configreRemoteConfig(){
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        fetchConfig()
    }
    
    func fetchConfig(){
        var expirationDuration = 3600
        if remoteConfig.configSettings.isDeveloperModeEnabled {
            expirationDuration = 0
        }
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)){
            status , error in
            if status == .success{
               // print("Config fetched")
                self.remoteConfig.activateFetched()
        
                let appReview = self.remoteConfig["app_review_14"].stringValue ?? "0"
                if let build = self.remoteConfig["current_ios_build"].stringValue, let appStoreURL = self.remoteConfig["app_store_url"].stringValue{
                    if Defaults[.showVersionDialogue]{
                    self.checkAppVersion(version: build,storeURL:appStoreURL)
                    }
                }
//                print("from config review= ", review)
//                print("from config review appreview = ",appReview)
//                print("from config review appreview calc = ",appReview == "1")
                Defaults[.isInReview] = appReview == "1"  //Usage : in preview view controller
                Defaults[.preview] = false// review == "1"
                
          //  print("from config review appreview = ",Defaults[.isInReview])
            }else{
//                print("config not fetched")
//                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
    
    private func checkAppVersion(version:String,storeURL:String){
            guard let dictBuild  = Bundle.main.infoDictionary, let buildNumber = dictBuild["CFBundleVersion"] as? String   else{
                return
            }
            guard let buildFromServer = Int(version) , let intNativeBuildNumber = Int(buildNumber) else {
                return
            }
        
//        if buildFromServer > intNativeBuildNumber {
//            showYesNoAlert(title: "", message: "New version of app is available.", yesTitle: "Update Now.", noTitle: "I'll do it later."){
//                answer in
//                if answer {
//                    UIApplication.shared.openURL(URL(string: storeURL)!)
//                }else{
//                    Defaults[.showVersionDialogue] = false
//                }
//            }
//            
//        }
    }
    
    
}
