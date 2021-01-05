//
//  ShopLandingViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ShopLandingViewController: RootViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnCouponCode: UIButton!
    @IBOutlet var creditCountDescLabel: UILabel!
    var toastLabel : UILabel!
    var timerRunning = false
    
    var favCount = Defaults[.myWishlistCount]
    var myNotificationCount = Defaults[.myNotificationCount]
    lazy var favouriteButton:UIButton = {
        let favIcon = #imageLiteral(resourceName: "ic_favourite_full")
        let favButton = UIButton(frame: CGRect(x: 0, y: 0, width: favIcon.size.width, height: favIcon.size.height))
        favButton.setImage(favIcon, for: .normal)
        favButton.addTarget(self, action: #selector(onFavButtonTapped), for: .touchUpInside)
        return favButton
    }()
    lazy var  wishlistBadge:UILabel = {
        let notificationBadge =  UILabel(frame: CGRect(x: (favouriteButton.frame.width / 2) + 7, y: favouriteButton.frame.height / 2.5, width: 22, height: 22))
        notificationBadge.textAlignment = .left
        notificationBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        notificationBadge.text = favCount.description
        notificationBadge.addRoundedCorner(radius: 11)
        notificationBadge.textColor = UIColor.white
        return notificationBadge
    }()
    
    lazy var notificationButton:UIButton = {
        let notificationIcon = #imageLiteral(resourceName: "ic_message_white")
        let notificationButton = UIButton(frame: CGRect(x: 0, y: 0, width: notificationIcon.size.width, height: notificationIcon.size.height))
        notificationButton.setImage(notificationIcon, for: .normal)
        notificationButton.addTarget(self, action: #selector(onNotificationButtonTap), for: .touchUpInside)
        return notificationButton
    }()
    
    lazy  var  notifBadge:UILabel = {
        let notificationBadge =  UILabel(frame: CGRect(x: 22 , y: 22 / 2.5, width: 22, height: 22))
        notificationBadge.textAlignment = .center
        notificationBadge.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        notificationBadge.text =  myNotificationCount.description
        notificationBadge.backgroundColor = AppTheme.Color.primaryRed
        notificationBadge.addRoundedCorner(radius: 11)
        notificationBadge.textColor = UIColor.white
        return notificationBadge
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtons()
        self.view.backgroundColor = AppTheme.Color.primaryBlue
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func onNotificationButtonTap(){
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let vc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onFavButtonTapped(){
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let wishlistVC = UIStoryboard.morePathway.instantiateViewController(withIdentifier: WishlistViewController.stringIdentifier) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistVC, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timerRunning = false
        getAppSetting()
        if Defaults[.notificatinForSellerCreditTx] {
            Defaults[.notificatinForSellerCreditTx] = false
            self.navigationController?.popToRootViewController(animated: true)
        }
        let availableCredits = Defaults[.userCreditCount]
        self.creditCountDescLabel.text = "You have (\(availableCredits)) credits"
        getCredit()
        
        self.favCount = Defaults[.myWishlistCount]
        updateWishlistBadge()
        updateNotifBadge()
    }
    
    @IBAction func onSellCreditButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        if !checkEmailAndMobileISEmpty() {
            let qrGeneratorViewController = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: TransferCreditLandingPageController.stringIdentifier) as! TransferCreditLandingPageController
            self.navigationController?.pushViewController(qrGeneratorViewController, animated: true)
        }
    }
    
    @IBAction func onScanQRButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        if !checkEmailAndMobileISEmpty() {
            let qrReaderViewController = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: QRReaderViewController.stringIdentifier) as! QRReaderViewController
            self.navigationController?.pushViewController(qrReaderViewController, animated: true)
        }
    }
    
    @IBAction func onPurchaseWithEpayButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        if !checkEmailAndMobileISEmpty() {
            let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: CreditPurchaseViewController.stringIdentifier) as! CreditPurchaseViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func onPurchaseWithCashButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        if !checkEmailAndMobileISEmpty(){
            if !timerRunning {
                self.showToast(message: "Locating closest credit stores to you.")
                timerRunning = true
            }
        }
    }
    
    
    @objc func textChanged(_ sender:Any){
        let tf = sender as! UITextField
        // enable OK button only if there is text
        // hold my beer and watch this: how to get a reference to the alert
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[1].isEnabled = (tf.text != "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // return textField.text.map{!$0.isEmpty}!
        return textField.text != ""
    }
    
    @IBAction func loadCouponCode(_ sender: UIButton) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        if !checkEmailAndMobileISEmpty(){
            var textField: UITextField?
            
            // create alertController
            let alertController = UIAlertController(title: "Please enter valid coupon code below.", message: "", preferredStyle: .alert)
            alertController.addTextField { (pTextField) in
                pTextField.addTarget(self, action: #selector(self.textChanged), for: .editingChanged)
                pTextField.delegate = self
                pTextField.placeholder = "Valid coupon code.."
                pTextField.clearButtonMode = .whileEditing
                pTextField.addRoundedCorner(radius: 5.0)
                pTextField.textAlignment = .center
                let heightConstraint = NSLayoutConstraint(item: pTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
                pTextField.addConstraint(heightConstraint)
                // pTextField.addConstraint(textField?.heightAnchor.constraint(equalToConstant: 50))
                pTextField.borderStyle = .none
                textField = pTextField
            }
            
            // create cancel button
            alertController.addAction(UIAlertAction(title: "No, I'll use later.", style: .cancel, handler: { (pAction) in
                alertController.dismiss(animated: true, completion: nil)
            }))
            
            // create Ok button
            alertController.addAction(UIAlertAction(title: "Use now.", style: .default, handler: { (pAction) in
                // when user taps OK, you get your value here
                let inputValue = textField?.text ?? ""
                self.showLoadingIndicator()
                ApiManager.sendRequest(toApi: .CouponCode(code: inputValue), onSuccess: {
                    status, response in
                    self.hideLoadingIndicator()
                    if status == 200 {
                        
                        if let error = response["error"].bool, !error{
                            if let result = response["data"].dictionary{
                                let availableCredit = result["available_credit"]?.int ?? Defaults[.userCreditCount]
                                Defaults[.userCreditCount] = availableCredit
//                                self.tabBarController?.tabBar.items?[2].badgeValue = "\(availableCredit)"
                                let message = result["message"]?.string ?? "Congratulations, you have got one credit."
                                self.showAlert(title: "", message: message)
                            }
                        }else{
                            let message = response["message"].string ?? "Already used coupon.Sorry you didn't get the credit."
                            self.showAlert(title: "", message: message)
                        }
                        
                    }else{
                        let message = response["message"].string  ?? "Invalid coupon code."
                        self.showAlert(title: "", message: message)
                    }
                }, onError: {
                    (error) in
                    self.showAlert(title: "", message: error.localizedDescription)
                    self.hideLoadingIndicator()
//                    print(error.localizedDescription)
                })
                alertController.dismiss(animated: true, completion: nil)
                
            }))
            alertController.actions[1].isEnabled = false
            // show alert controller
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func setupBarButtons() {
        
        if myNotificationCount != 0 {
            self.notificationButton.addSubview(self.notifBadge)
        }
        let barButtonNotif = UIBarButtonItem(customView: self.notificationButton)
        
        if favCount != 0 {
            self.favouriteButton.addSubview(self.wishlistBadge)
        }
        let barButtonFav = UIBarButtonItem(customView: self.favouriteButton)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 20.0
        self.navigationItem.rightBarButtonItems = [spacer, barButtonNotif, spacer, barButtonFav]
    }
    
    func showToast(message : String) {
        toastLabel =  UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 175, y: self.view.frame.size.height/2, width: 350, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        // toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        let _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.stopTimer), userInfo: nil, repeats: false)
        
    }
    
    func updateWishlistBadge(){
        self.favCount = Defaults[.myWishlistCount]
        if self.favCount == 0 {
            if self.wishlistBadge.isDescendant(of: self.favouriteButton){
                wishlistBadge.removeFromSuperview()
            }
            return
        }
        if !self.wishlistBadge.isDescendant(of: self.favouriteButton){
            self.favouriteButton.addSubview(wishlistBadge)
        }
        wishlistBadge.text = self.favCount.description
    }
    
    func updateNotifBadge(){
        self.myNotificationCount = Defaults[.myNotificationCount]
        if self.myNotificationCount == 0 {
            if self.notifBadge.isDescendant(of: self.notificationButton){
                notifBadge.removeFromSuperview()
            }
            return
        }
        if !self.notifBadge.isDescendant(of: self.notificationButton){
            self.notificationButton.addSubview(notifBadge)
        }
        notifBadge.text = self.myNotificationCount.description
    }
    
    @objc  func stopTimer(){
        toastLabel.removeFromSuperview()
        let vc = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: ShopMapViewController.stringIdentifier) as! ShopMapViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func getAppSetting(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .AppSetting, onSuccess: {
            [weak self]  status , response  in
            print(status)
            print(response)
            if let discountedCredit = response["data"]["discounted_credit"].int {
                Defaults[.discountedCredit] = discountedCredit
                
            }
            if let promotionMode = response["data"]["promotion_mode"].int{
                Defaults[.promotionMode] = promotionMode == 1
//                if let tabItem = self?.tabBarController?.tabBar.items?[2] {
//                    //                    tabItem.isEnabled = promotionMode == 0
//                    if promotionMode == 1 {
//                        tabItem.isEnabled = true
//                        tabItem.badgeValue = nil
//                    }else{
//                        tabItem.isEnabled = true
//                    }
//                }
            }
            if let vehiclesCount = response["data"]["vehicles_count"].int{
                Defaults[.bikeCount] = vehiclesCount
                
            }
            if let normalCredit = response["data"]["normal_credit"].int{
                Defaults[.normalCredit] = normalCredit
            }
            if let unreadNotifications = response["data"]["unread_notification"].int{
                Defaults[.myNotificationCount] = unreadNotifications
                self?.updateNotifBadge()
            }
            }, onError: {
                appError in
                
        })
    }
    
    
    
    
    private func checkEmailAndMobileISEmpty()->Bool{
        if Defaults[.userEmail] == "" || Defaults[.userMobile] == "" {
            let navVC = UIStoryboard.main.instantiateViewController(withIdentifier: CollectInfoNavViewController.stringIdentifier) as! CollectInfoNavViewController
            let collectVc = navVC.viewControllers.first as? UserInformationFormController
            collectVc?.userEmail = Defaults[.userEmail]
            collectVc?.userMobile = Defaults[.userMobile]
            self.present(navVC, animated: true, completion: nil)
            return true
        }
        return false
    }
    
    private func getCredit(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .getCredit, onSuccess: {
            [weak self] status , response in
            //  self?.hideLoadingIndicator()
            if status == 200 {
                if let credit = response["data"].int {
                    Defaults[.callGetCreditInShop] = false
                    Defaults[.userCreditCount] = credit
                    let ss =  "You have (\(credit)) credit\(credit<2 ? "":"s")"
                    print(ss)
                    self?.creditCountDescLabel.text = "You have (\(credit)) credit\(credit<2 ? "":"s")"
                    let tabArray = self?.tabBarController?.tabBar.items
                    let tabItem = tabArray?[2]
//                    tabItem?.badgeValue = "\(credit)"
                }
            }
            
            }, onError: {error in
                //self.hideLoadingIndicator()
                //self.showAlert(title: "Error", message: error.localizedDescription)
                
        })
        //   self.creditCountDescLabel.text = "You have (\(Defaults[.userCreditCount])) credits"
    }
    
    
}
