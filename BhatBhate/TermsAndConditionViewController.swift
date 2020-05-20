//
//  TermsAndConditionViewController.swift
//  BhatBhate
//
//  Created by sunil-71 on 5/17/18.
//  Copyright © 2018 Andmine. All rights reserved.
//

import UIKit
import WebKit
class TermsAndConditionViewController: RootViewController,WKUIDelegate {

    
    override func viewDidLoad() {
        super.viewDidLoad()
setupViews()
      
        // Do any additional setup after loading the view.
    }

    func setupViews(){
        var webView:WKWebView!
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: self.view.bounds, configuration: webConfiguration)
        webView.uiDelegate = self
        self.view.addSubview(webView)
//        webView.translatesAutoresizingMaskIntoConstraints=false
//        self.view.translatesAutoresizingMaskIntoConstraints=false
//        self.view.addSubview(webView)
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[webView]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView" : webView]))
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[webView]-(0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["webView" : webView]))
//        //3.Loading with URL
        let myURL = URL(string: "http://bhatbhate.net/terms-and-condition")
        let myRequest = URLRequest(url: myURL!)
        
        webView.load(myRequest)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
