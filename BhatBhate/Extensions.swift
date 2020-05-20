//
//  Extensions.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults
extension UIStoryboard {
    
    class var main:UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    class var buyPathway:UIStoryboard {
        return UIStoryboard(name: "BuyPathway", bundle: nil)
    }
    
    class var sellPathway:UIStoryboard {
        return UIStoryboard(name: "SellPathway", bundle: nil)
    }
    
    class var shopPathway:UIStoryboard {
        return UIStoryboard(name: "ShopPathway", bundle: nil)
    }
    
    class var morePathway:UIStoryboard {
        return UIStoryboard(name: "MorePathway", bundle: nil)
    }
}

extension Notification.Name {
    static let updateBadge = Notification.Name("UpdateBadge")
}


extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}


extension UIColor {

    class func from(r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat) -> UIColor {
        
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    /// Converts Hex format string to UIColor
    ///
    /// - Parameter hex: hexadecimal representation of color. eg, #cccccc
    /// - Returns: UIColor representing the format
    class func from (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIView {
    
    func addRoundedCorner(radius:CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    class var stringIdentifier:String {
        return String(describing: self)
    }
    
    func addBorder(width:CGFloat, color:UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    // Embedded Message Label
    
    func showMessageLabel(embeddedLabel:UILabel, message:String, textColor:UIColor = UIColor.darkGray.withAlphaComponent(0.8)) {
        
        self.backgroundColor = UIColor.white
        
        embeddedLabel.text = message
        embeddedLabel.numberOfLines = 0
        embeddedLabel.translatesAutoresizingMaskIntoConstraints = false
        embeddedLabel.textAlignment = .center
        embeddedLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        embeddedLabel.textColor = textColor
        
        self.addSubview(embeddedLabel)
        
        NSLayoutConstraint(item: embeddedLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: embeddedLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: embeddedLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16).isActive = true
        NSLayoutConstraint(item: embeddedLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        self.bringSubviewToFront(embeddedLabel)
    }
    
    func hideMessageLabel(embeddedLabel:UILabel?) {
        embeddedLabel?.removeFromSuperview()
    }
    
    // Embedded Activity Indicator
    
    func showLoadingIndicator(activityIndicator: UIActivityIndicatorView) {
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        
        NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
        activityIndicator.startAnimating()
        self.bringSubviewToFront(activityIndicator)
    }
    
    func hideLoadingIndicator(activityIndicator: UIActivityIndicatorView?) {
        
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
    }
    
}

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIViewController {
    
    class var stringIdentifier:String {
        return String(describing: self)
    }
    
    
}

extension String{
    func formattedURL() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    func removeDotZero()->String{
        return self.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "0", with: "")
    }
    
    func boldName(name:String)->NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15.0)])
        let range = (self as NSString).range(of: name)
        let boldFontAttribute = [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 15.0)]
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    func boldMultipleName()->NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 15.0),NSAttributedString.Key.foregroundColor:AppTheme.Color.primaryBlue])
        return attributedString
    }
    
}

extension Double {
    var removeZero:String? {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 0
        return nf.string(from: NSNumber(value: self))
        //return nf.stringFromNumber(self)!
    }
    
    func formatCurrency()->String {
        let strPr = self.removeZero
        guard var strPrice = strPr else {
            return "-"
        }
        switch strPrice.count {
        case 4,5:
            strPrice.insert(",", at: strPrice.index(strPrice.endIndex, offsetBy: -3))
        case 6,7,8:
            strPrice.insert(",", at: strPrice.index(strPrice.endIndex, offsetBy: -3))
            strPrice.insert(",", at: strPrice.index(strPrice.endIndex, offsetBy: -6))
            if strPrice.count == 10
            {
              strPrice.insert(",", at: strPrice.index(strPrice.endIndex, offsetBy: -9))
            }
        default:
            break
        }
        return strPrice
    }
    
}

extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setBorderToLeft(){
        let leftBorder = CALayer()
        leftBorder.frame = CGRect(x: 0.0, y: 0, width: 1.0, height: self.frame.size.height)
        leftBorder.backgroundColor = UIColor.from(hex: "E1E5F2").cgColor
        self.layer.addSublayer(leftBorder)
        
    }
    
    func addBorder(){
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
    }
    
    func setCustomPlaceholder(text:String){
        self.attributedPlaceholder = NSAttributedString(string:text,attributes:[NSAttributedString.Key.foregroundColor:UIColor.from(hex: "#9f9f9f")])
    }
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
