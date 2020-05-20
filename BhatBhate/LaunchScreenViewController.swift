//
//  LaunchScreenViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 1/17/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class LaunchScreenViewController: UIViewController {
    
    // LTR 0 - 5
    @IBOutlet var countLabels: [UILabel]!
    @IBOutlet var horizontalLineView: UIView!
    
    private var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBikeCountLabel()
    }

    
    func setupBikeCountLabel() {
        
        let bikeCount = Defaults[.bikeCount]
        let bikeCountInStr = "\(bikeCount)"
        let bikeCountStrArr = bikeCountInStr.map{ "\($0)" }
        
        // Show labels only if there are bikes uploaded
        guard bikeCount > 0 else { return }
        _ = countLabels.map{ $0.isHidden = false }
        
        
        for (index,str) in bikeCountStrArr.reversed().enumerated() {
            
            let labelIndex = 5 - index
            
            if labelIndex < 0 { break }
            
            countLabels[labelIndex].text = str
        }
    }
    
    
    func setupViews() {
        
        self.horizontalLineView.backgroundColor = AppTheme.Color.primaryRed
        self.view.backgroundColor = AppTheme.Color.primaryRed
        
        for lbl in countLabels{
            lbl.addRoundedCorner(radius: 4)
            lbl.backgroundColor = AppTheme.Color.primaryBlue
            lbl.text = "0"
            lbl.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissViewController), userInfo: nil, repeats: false)
    }
    
    
    @objc func dismissViewController() {
        
        self.timer.invalidate()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        //if Defaults[.isLoggedIn] {
            
            let tabBarViewController = UIStoryboard.main.instantiateViewController(withIdentifier: TabBarViewController.stringIdentifier) as! UITabBarController
            window?.rootViewController = tabBarViewController
            
//        } else {
//
//            let navController = UIStoryboard.main.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
//            window?.rootViewController = navController
//        }
    }
    
}
