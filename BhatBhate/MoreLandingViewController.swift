//
//  MoreLandingViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class MoreLandingViewController: RootViewController {

    @IBOutlet weak var labelWishlistCount: UILabel!
    @IBOutlet weak var iconWishLish: UIImageView!
    @IBOutlet weak var btnTransaction: UIButton!
    @IBOutlet weak var lblTransaction: UILabel!
    
    var favCount = Defaults[.myWishlistCount]
    var myNotificationCount = Defaults[.myNotificationCount]

    
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
      
        if Defaults[.noEmailOrMobile] {
            showEditInformation()
        }
        setupBarButtons()
        self.view.backgroundColor = AppTheme.Color.primaryBlue
    }

    @objc func onNotificationButtonTap(){
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let vc = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    @objc func onFavButtonTapped(){
//        let wishlistVC = UIStoryboard.morePathway.instantiateViewController(withIdentifier: WishlistViewController.stringIdentifier) as! WishlistViewController
//        self.navigationController?.pushViewController(wishlistVC, animated: true)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblTransaction.isHidden = Defaults[.preview]
        btnTransaction.isHidden = Defaults[.preview]
        iconWishLish.isHidden = Defaults[.myWishlistCount] == 0
        labelWishlistCount.isHidden = Defaults[.myWishlistCount] == 0
        labelWishlistCount.text = Defaults[.myWishlistCount].description
        if  Defaults[.accessToken] == nil {
//            self.tabBarController?.tabBar.items?[2].badgeValue = nil
        }
        getAppSetting()
        updateNotifBadge()
    }
    
    private func setupBarButtons() {
        
        if myNotificationCount != 0 {
            self.notificationButton.addSubview(self.notifBadge)
        }
        let barButtonNotif = UIBarButtonItem(customView: self.notificationButton)
        
//        if favCount != 0 {
//            self.favouriteButton.addSubview(self.wishlistBadge)
//        }
       // let barButtonFav = UIBarButtonItem(customView: self.favouriteButton)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 20.0
        self.navigationItem.rightBarButtonItems = [spacer, barButtonNotif, spacer]
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
    
    private func getAppSetting(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .AppSetting, onSuccess: {
            status , response  in
           
            if let discountedCredit = response["data"]["discounted_credit"].int {
                Defaults[.discountedCredit] = discountedCredit
            }
            
            if let promotionMode = response["data"]["promotion_mode"].int{
                   Defaults[.promotionMode] = promotionMode == 1
//                if promotionMode == 1{
//                    if !Defaults[.preview]{
//                    self.tabBarController?.tabBar.items?[2].isEnabled = false
//                    self.tabBarController?.tabBar.items?[2].badgeValue = nil
//                    }
//                    
//                }else{
//                    self.tabBarController?.tabBar.items?[2].isEnabled = true
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
                self.updateNotifBadge()
            }
        }, onError: {
            appError in
            
        })
    }
    
    private func showEditInformation(){
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onProfileButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let profileView = UIStoryboard.morePathway.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(profileView, animated: true)
        
    }
    
    @IBAction func onWishlistButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let wishlistController = UIStoryboard.morePathway.instantiateViewController(withIdentifier: WishlistViewController.stringIdentifier) as! WishlistViewController
        self.navigationController?.pushViewController(wishlistController, animated: true)
        
    }
    
    @IBAction func onTransactionHistoryButtonTap(_ sender: Any) {
        guard let _ = Defaults[.accessToken] else {
            showLoginScreen()
            return
        }
        let transactionController = UIStoryboard.morePathway.instantiateViewController(withIdentifier: TransactionHistoryViewController.stringIdentifier) as! TransactionHistoryViewController
        self.navigationController?.pushViewController(transactionController, animated: true)
    }
    
    
    
}
