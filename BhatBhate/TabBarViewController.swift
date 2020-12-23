//
//  TabBarViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 12/15/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class TabBarViewController: UITabBarController {

    var separator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   //        self.tabBar.backgroundColor = AppTheme.Color.appbargreen
                self.tabBar.isTranslucent = false
                self.tabBar.tintColor = AppTheme.Color.primaryRed
                self.tabBar.barTintColor = AppTheme.Color.appbargreen
        //        self.tabBar.backgroundImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        checkEmailAndMobile()
        //separator.removeFromSuperview()
        setupTabBarSeparators()
     print("in viewdid layout subviews")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if (Defaults[.preview]){
            return
        }
        let tabItem = self.tabBar.items?[2]
        if Defaults[.promotionMode] {
            tabItem?.isEnabled = false
            tabItem?.badgeValue = nil
        }else{
            tabItem?.isEnabled = true
            let credit = Defaults[.userCreditCount] == 0 ? nil : "\(Defaults[.userCreditCount])"
            tabItem?.badgeValue = credit
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       getCredit()
    }
    
    func setupTabBarSeparators() {
        
        if separator.isDescendant(of: self.tabBar){
            print("separator is there")
            let separotr = self.tabBar.subviews
            for views in separotr {
                print(views)
                print("tag is = ",views.tag)
                if (views.tag == 100 || views.tag == 101 || views.tag == 102 || views.tag == 103) {
                    views.removeFromSuperview()
                }
            }
        }else{
            print("no separator")
        }
        
        var itemWidth = floor(self.tabBar.frame.size.width / CGFloat(self.tabBar.items!.count))
        print(itemWidth)
        self.tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.from(r: 224, g: 228, b: 241, a: 0.5).cgColor//(hex: "E0e4f1").cgColor
        tabBar.clipsToBounds = true
        // this is the separator width.  0.5px matches the line at the top of the tab bar
        let separatorWidth: CGFloat = 0.5
        
        // iterate through the items in the Tab Bar, except the last one
        for i in 0...(self.tabBar.items!.count - 1) {
            //  print("count=\(i)")
            itemWidth = i == 2 ? itemWidth + 4.0 : itemWidth
            // make a new separator at the end of each tab bar item
            separator = UIView(frame: CGRect(x: itemWidth * CGFloat(i + 1) - CGFloat(separatorWidth / 2), y: 0, width: CGFloat(separatorWidth), height: self.tabBar.frame.size.height))
            separator.tag = i + 100
            // set the color to light gray (default line color for tab bar)
            separator.backgroundColor = i == 3 ? UIColor.clear : UIColor.from(r: 224, g: 228, b: 241, a: 0.3)
            self.tabBar.addSubview(separator)
            
        }
    }
    
    private func checkEmailAndMobile(){
        if Defaults[.userEmail] == "" || Defaults[.userMobile] == "" {
            let navVC = UIStoryboard.main.instantiateViewController(withIdentifier: CollectInfoNavViewController.stringIdentifier) as! CollectInfoNavViewController
            let collectVc = navVC.viewControllers.first as? UserInformationFormController
            collectVc?.userEmail = Defaults[.userEmail]
            collectVc?.userMobile = Defaults[.userMobile]
            self.present(navVC, animated: true, completion: nil)
        }
    }
    
    private func setupTabImages() {
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isDeviceIpad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func isDeviceIphone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    private func getCredit(){
        guard let _ = Defaults[.accessToken] else {
            return
        }
        ApiManager.sendRequest(toApi: .getCredit, onSuccess: {status , response in
            // print("in tabbarviewcontroller")
            if status == 200 {
                if let promotionMode = response["promotion_mode"].int{
                    Defaults[.promotionMode] = promotionMode == 1
                }
                
                if let credit = response["data"].int {
                    Defaults[.callGetCreditInShop] = false
                    Defaults[.userCreditCount] = credit
                    let tabArray = self.tabBarController?.tabBar.items
                    let tabItem = tabArray?[2]
                    if Defaults[.promotionMode]{
                        tabItem?.isEnabled = false
                        tabItem?.badgeValue = nil
                    }else{
                        tabItem?.isEnabled = true
                        tabItem?.badgeValue = "\(credit)"
                        let strCredit = credit == 0 ? nil : "\(credit)"
                    self.tabBar.items?[2].badgeValue = strCredit
                    }
                }
            }
            
        }, onError: { _ in
            
            
        })
        
    }
   
}
