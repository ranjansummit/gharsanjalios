//
//  SellInformationViewControllerOne.swift
//  BhatBhate
//
//  Created by sunil-71 on 12/15/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import Starscream
import SwiftyUserDefaults
class SellInformationViewControllerOne: RootViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textBikeBrand: UITextField!
    @IBOutlet weak var textBikeModel: UITextField!
    @IBOutlet weak var textBikeEngineCapacity: UITextField!
    @IBOutlet weak var textBikeMilage: UITextField!
    var brandID:Int?
    var modelID:Int?
    var engineID:Int?
    var selectedBrandName:String?
    var selectedModelName:String?
    var selectedEngineName:String?
    var bikeProperties:BikeProperties?
    var selectedBrand:Brands?
    var  selectedModel:Models?
    var selectedEngineCapacity:Engine!
    var editBike:Bike?
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.title = "Sell a bike"
        self.view.backgroundColor = UIColor.white
        setupScrollViewForKeyboardAppearance(scrollView: scrollView)
        getVehicleProperties()
        
        guard let myBike = self.editBike else {
            return
        }
        
        debugPrint(myBike.sellerImage)
         GlobalVar.sharedInstance.answer1["id"] = "\(myBike.id!)"
        self.textBikeBrand.text = myBike.brandName
        self.textBikeModel.text = myBike.modelName
        self.textBikeMilage.text = myBike.mileage
        self.textBikeEngineCapacity.text = myBike.engineCapacity
        self.engineID = myBike.engineCapacityID
        self.brandID = myBike.brandID
        self.modelID = myBike.modelID
        self.selectedBrandName = myBike.brandName
        self.selectedModelName = myBike.modelName
        self.selectedEngineName = myBike.engineCapacity
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
//        if Defaults[.promotionMode]{
//            if !Defaults[.preview]{
//            self.tabBarController?.tabBar.items?[2].isEnabled = false
//            self.tabBarController?.tabBar.items?[2].badgeValue = nil
//            }
//        }else{
//            self.tabBarController?.tabBar.items?[2].isEnabled = true
//        }
    }
    
    private func getVehicleProperties(){
        LoadingIndicatorView.show()
        ApiManager.sendRequest(toApi: .getVehicleProperties, onSuccess: {
            status , response in
            LoadingIndicatorView.hide()
            let data = response["data"].dictionary
            guard let bikeData = data else {
                return
            }
            self.bikeProperties = BikeProperties(dictionary: bikeData)
           
            // to autopopulate model and engine capacity
            guard let _ = self.editBike else {
                return
            }
            
            let brands = self.bikeProperties?.brands
            for brand in brands!{
                if brand.brand_id == self.brandID{
                    self.selectedBrand = brand
                    let models = brand.models
                    for model in models!{
                        if model.model_id == self.modelID{
                            self.selectedModel = model
                            let engines = model.engines
                            for engine in engines! {
                                if engine.id == self.engineID{
                                    self.selectedEngineCapacity = engine
                                }
                            }
                            
                        }
                    }
                }
            }

          //  dump(self.bikeProperties)
        }, onError: {
            httpError in
            self.hideLoadingIndicator()
        })
    }
    
    
    @IBAction func actionGetModel(_ sender: UIButton) {
        let listVC = UIStoryboard.main.instantiateViewController(withIdentifier: ListViewController.stringIdentifier) as! ListViewController
        guard let brandSelected = self.selectedBrand else {
            showAlert(title: "Error", message: "Please select brand first")
            return
        }
        listVC.list = brandSelected.models
        listVC.selectedName = self.selectedModelName
        listVC.listType = .Model
        listVC.pageTitle = "Select model"
        listVC.selectedIndex = {
            [unowned self] selectedIndex in
            if let selectedModel = self.selectedBrand?.models?[selectedIndex!] {
                if selectedModel.model_id == self.modelID {
                    return
                }
                self.selectedModel = selectedModel
                
                self.selectedModelName = selectedModel.model_name
                self.modelID  = selectedModel.model_id
                self.textBikeModel.text = self.selectedModelName
                
                self.textBikeEngineCapacity.text = ""
                self.engineID = nil
                self.selectedEngineName = nil
                if let engines = self.selectedModel?.engines, engines.count == 1 {
                    self.textBikeEngineCapacity.text = engines[0].capacity
                    self.engineID = engines[0].id
                    self.selectedEngineName = engines[0].capacity
                }
            }
        }
        self.navigationController?.pushViewController(listVC, animated: true)
        
    }
    
    @IBAction func actionGetBrands(_ sender: UIButton) {
        let listVC = UIStoryboard.main.instantiateViewController(withIdentifier: ListViewController.stringIdentifier) as! ListViewController
        listVC.list = self.bikeProperties?.brands
        listVC.selectedName = self.selectedBrandName
        listVC.listType = .Brand
        listVC.pageTitle = "Select brand"
        listVC.selectedIndex = {
            [unowned self] selectedIndex in
            if let selectedBrand = self.bikeProperties?.brands?[selectedIndex!] {
                if selectedBrand.brand_id == self.brandID {
                    return
                }
                
                self.selectedBrand = selectedBrand
                self.selectedBrandName = selectedBrand.brand_name
                
                self.textBikeBrand.text = self.selectedBrandName
                self.brandID = selectedBrand.brand_id
                
                self.textBikeModel.text = ""
                self.textBikeEngineCapacity.text = ""
                
                self.modelID = nil
                self.engineID = nil
                
                self.selectedModelName = nil
                self.selectedEngineName = nil
                
            }
        }
        self.navigationController?.pushViewController(listVC, animated: true)
    }
    
    @IBAction func actionGetEngineCap(_ sender: UIButton) {
        guard  let modelSelected = self.selectedModel else {
            showAlert(title: "Error", message: "Please select model first.")
            return
        }
        
        let listVC = UIStoryboard.main.instantiateViewController(withIdentifier: ListViewController.stringIdentifier) as! ListViewController
        
        listVC.list = modelSelected.engines
        listVC.listType = .EngineCapacity
        listVC.pageTitle = "Select engine capacity"
        listVC.selectedName = self.selectedEngineName
        listVC.selectedIndex = {
            [unowned self]  selectedIndex in
            if let selectedEngine = self.selectedModel?.engines?[(selectedIndex)!]{
                self.selectedEngineName = selectedEngine.capacity
                self.engineID = selectedEngine.id
                self.textBikeEngineCapacity.text = self.selectedEngineName
                
            }
        }
        self.navigationController?.pushViewController(listVC, animated: true)
        
    }
    
 
    
    @IBAction func btnNextAction(_ sender: UIButton) {
        let bikeBrand = textBikeBrand.text
        let bikeModel = textBikeModel.text
        let engineCapacity = textBikeEngineCapacity.text
        let milage = textBikeMilage.text
        
        if let brandID = self.brandID {
            if let modelID = self.modelID{
                if let engineID = self.engineID {
                    if milage?.count != 0{
                        GlobalVar.sharedInstance.answer["brand_id"] = brandID
                        GlobalVar.sharedInstance.answer["brand_name"] = bikeBrand
                        GlobalVar.sharedInstance.answer["model_id"] = modelID
                        GlobalVar.sharedInstance.answer["model_name"] = bikeModel
                        GlobalVar.sharedInstance.answer["engine_id"] = engineID
                        GlobalVar.sharedInstance.answer["engine_capacity"] = engineCapacity
                        
                        GlobalVar.sharedInstance.answer["mileage"] = milage!
                        
                        GlobalVar.sharedInstance.answer1["brand_id"] = "\(brandID)"
                        GlobalVar.sharedInstance.answer1["brand_name"] = bikeBrand
                        GlobalVar.sharedInstance.answer1["model_id"] = "\(modelID)"
                        GlobalVar.sharedInstance.answer1["model_name"] = bikeModel
                        GlobalVar.sharedInstance.answer1["engine_id"] = "\(engineID)"
                        GlobalVar.sharedInstance.answer1["engine_capacity"] = engineCapacity
                        
                        GlobalVar.sharedInstance.answer1["mileage"] = milage!
                        performSegue(withIdentifier: "ToSecondVC", sender: self)
                        
                    }else{
                        //empty milage
                        showAlert(title: "", message: "Please give mileage for your bike.")
                    }
                }else {
                    // empty engine capacity
                    showAlert(title: "", message: "Please select engine capacity.")
                }
            }else{
                // empty model
                showAlert(title: "", message: "Please select bike model.")
            }
        }else {
            // emmpty brand
            showAlert(title: "", message: "Please select bike brand.")
        }
    }
    
    @IBAction func actionNext(_ sender: UIBarButtonItem) {
        
       
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToSecondVC" {
            let destinationVC = segue.destination as! SellInformationViewControllerTwo
            destinationVC.editBike = self.editBike
        }
    }
    
    
}
