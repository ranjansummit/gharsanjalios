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
    
    @IBOutlet weak var quote: UILabel!
    private var timer: Timer!
    @IBOutlet weak var loader_iv: UIImageView!
    
    @IBOutlet weak var version: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

   

        var myEnglishArray: [String] = []
        if let URL = Bundle.main.url(forResource: "Values", withExtension: "plist") {
            if let englishFromPlist = NSArray(contentsOf: URL) as? [String] {
                myEnglishArray = englishFromPlist

              }
            }
        let randomInt = Int.random(in: 0..<myEnglishArray.count)
        quote.text = myEnglishArray[randomInt]
        
         
        
        setupViews()
    }

    
 

    func setupViews() {
        
        self.view.setGradientBackground(colorOne:AppTheme.Color.gradgreen , colorTwo: AppTheme.Color.gradyellow)
        let jeremyGif = UIImage.gifImageWithName("loader")
        loader_iv.image = jeremyGif
        let versionval =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        version.text = "version: "+versionval!
        version.sizeToFit()
        quote.sizeToFit()
        

        

        
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
