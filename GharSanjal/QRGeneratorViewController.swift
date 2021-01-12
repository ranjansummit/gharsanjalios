//
//  QRGeneratorViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 10/17/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class QRGeneratorViewController: RootViewController {

    @IBOutlet var QRImageView: UIImageView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet weak var transferHeader: UILabel!
    @IBOutlet weak var textAskBuyer: UILabel!
    
    public var codeData:Data?
    var creditQuantity:Int!
    var alphaCode:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let data = codeData else {
            self.showAlert(title: "", message: "Invalid data for QR Code")
            return
        }
        
        generateQRCode(data: data)
      
     //   self.title = "Transfer Confirmation"
        let textCredit = creditQuantity > 1 ? "credits" : "credit"
        self.transferHeader.text = "You are agreeing to sell and transfer \(creditQuantity!) \(textCredit) for Rs. \(creditQuantity*Defaults[.normalCredit])"
        self.textAskBuyer.text = "Ask the buyer to scan this QR code in the BhatBhate app under credits section and pay cash payment of Rs. \(creditQuantity*Defaults[.normalCredit]) at the same time."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    @IBAction func actionSwictchCode(_ sender: Any) {
        let codeVC = UIStoryboard.shopPathway.instantiateViewController(withIdentifier: ShowCodeViewController.stringIdentifier) as! ShowCodeViewController
        codeVC.alphaCode = self.alphaCode
        codeVC.creditCount = creditQuantity
        self.navigationController?.pushViewController(codeVC, animated: true)
    }
    
    func generateQRCode(data:Data) {
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        
//        let dict = ["title":"QR Test","message":"Testing QR Code generator in Dictionary"]
//        let stringRepr = dict.description
//
//        let dataRepr = stringRepr.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        qrFilter?.setValue(data, forKey: "inputMessage")
        qrFilter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        if let qrImage = qrFilter?.outputImage {
            
            let scaleX = QRImageView.frame.width / qrImage.extent.size.width
            let scaleY = QRImageView.frame.height / qrImage.extent.size.height
            
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            let image = UIImage(ciImage: qrImage.transformed(by: transform))
            QRImageView.image = image
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
