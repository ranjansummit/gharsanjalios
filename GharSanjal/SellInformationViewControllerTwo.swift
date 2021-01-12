//
//  SellInformationViewControllerTwo.swift
//  BhatBhate
//
//  Created by sunil-71 on 12/15/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class SellInformationViewControllerTwo: RootViewController {

    @IBOutlet weak var vehicleLot: UITextField!
    @IBOutlet weak var rating: StarRatingView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var odometerReading: UITextField!
    
    @IBOutlet weak var sellingPrice: UITextField!
    
    var editBike:Bike?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupScrollViewForKeyboardAppearance(scrollView: scrollView)
    //    self.title = "Sell a bike"
        rating.currentRating = 1
        
        // Auto populate in case of back button
        if let lot =   GlobalVar.sharedInstance.answer["lot"] as? String {
            vehicleLot.text = lot
        }
        
        if let odometer = GlobalVar.sharedInstance.answer["odometer"] as? String{
            self.odometerReading.text = odometer
        }
        
        if let price = GlobalVar.sharedInstance.answer["price"] as? String{
            self.sellingPrice.text = price
        }
        
        if let rating = GlobalVar.sharedInstance.answer["rating"] as? Int{
            self.rating.currentRating = rating
        }
        
        
        // Edit bike section
        guard let bike = self.editBike else {
            return
        }
      //  print("seller image=",bike.sellerImage)
        self.vehicleLot.text = bike.vehicleLot
        self.rating.currentRating = bike.conditionRating ?? 0
        let odometer = bike.odometerReading ?? "0.0"

        self.odometerReading.text = "\(Int(Double(odometer) ?? 0.0))"
        self.sellingPrice.text = "\( Int(bike.price ?? "0") ?? 0)"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        let lot = vehicleLot.text
        let odometer = odometerReading.text
        let sellPrice = sellingPrice.text
        let rating = self.rating.currentRating
        if lot?.count != 0 {
            if odometer?.count != 0 {
                if sellPrice?.count != 0 {
                    GlobalVar.sharedInstance.answer["lot"] = lot!
                    GlobalVar.sharedInstance.answer["odometer"] = odometer!
                    GlobalVar.sharedInstance.answer["price"] = sellPrice!
                    GlobalVar.sharedInstance.answer["rating"] = rating
                    
                    GlobalVar.sharedInstance.answer1["lot"] = lot!
                    GlobalVar.sharedInstance.answer1["odometer"] = odometer!
                    GlobalVar.sharedInstance.answer1["price"] = sellPrice!
                    GlobalVar.sharedInstance.answer1["rating"] = "\(rating)"
                    performSegue(withIdentifier: "ToThirdVC", sender: self)
                }else{
                    //print("empty selling price")
                    showAlert(title: "", message: "Please enter selling price of your bike.")
                }
            }else{
                //print("empty odometer")
                showAlert(title: "", message: "Please enter odometer readings of your bike.")
            }
        }else{
            //print("empty lot")
            showAlert(title: "", message: "Please enter lot of your bike.")
            
        }
    }
    
    @IBAction func actionNext(_ sender: UIBarButtonItem) {
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToThirdVC" {
            let destinationVC = segue.destination as! AddPhotosViewController
            destinationVC.editBike = self.editBike
        }
    }
    
}
