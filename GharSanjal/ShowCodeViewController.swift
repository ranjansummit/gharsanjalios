//
//  ShowCodeViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 5/8/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class ShowCodeViewController: UIViewController {
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblAskBuyer: UILabel!
    @IBOutlet weak var lblConf: UILabel!
    
    var creditCount:Int!
    var alphaCode:String!
    var code = ""{
        didSet {
            lblCode.attributedText = NSAttributedString(string: code,attributes:[ NSAttributedString.Key.kern: 15.0])
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        code = alphaCode
          let textCredit = creditCount > 1 ? "credits" : "credit"
        lblConf.text = "You are agreeing to sell and transfer \(creditCount!) \(textCredit) for Rs. \(creditCount*Defaults[.normalCredit])"
        lblAskBuyer.text = "Ask the buyer to enter above code in the BhatBhate app under credits section and pay cash payment of Rs. \(creditCount*Defaults[.normalCredit]) at the same time."
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
