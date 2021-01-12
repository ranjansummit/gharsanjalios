//
//  BikeSearchFilterViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit

protocol BikeSearchFilterDelegate:class {
    func didChangeSearchFilter(brand:String,model:String,price:String,condition:Int)
    func didClickedCancel(wasSearchOn:Bool)
}

class BikeSearchFilterViewController: RootViewController, BikeSearchFilterViewPresentation {
    
    @IBOutlet weak var imgChecked: UIImageView!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var brandTextField: UITextField!
    @IBOutlet var modelTextField: UITextField!
    @IBOutlet var priceSlider: UISlider!
    @IBOutlet var priceLabel: UILabel!
    var isOwnSearch = false
    @IBOutlet weak var starRatingView: StarRatingView!{
        didSet {
            starRatingView.currentRating = 1
        }
    }
    
    public var presenter:BikeSearchFilterPresenter!
    public weak var delegate: BikeSearchFilterDelegate!
    var searchHistory:(brand: String, model: String, price: String,condition:Int)?
    var pickerView:UIPickerView!
    var activeTextFieldTag:Int = 0
    var bikeConditionAny = true {
        didSet{
        imgChecked.image = bikeConditionAny ? #imageLiteral(resourceName: "ic_checked") : #imageLiteral(resourceName: "ic_unchecked")
            if bikeConditionAny {
                starRatingView.currentRating = 1
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        presenter = BikeSearchFilterPresenter(viewDelegate: self)
        presenter.searchHistory = self.searchHistory
        presenter.fetchSearchFilter()
       bikeConditionAny = true
        
    }
    
    func setupViews() {
        
        setupScrollViewForKeyboardAppearance(scrollView: scrollView)
        
        UIApplication.shared.statusBarView?.backgroundColor = AppTheme.Color.primaryBlue
        UIApplication.shared.statusBarStyle = .lightContent
        
        navigationBar.barTintColor = AppTheme.Color.primaryBlue
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        starRatingView.starRatingClicked = {
            [unowned self] in
            self.bikeConditionAny = false
        }
       // self.scrollView.showsVerticalScrollIndicator = false
        //self.scrollView.showsHorizontalScrollIndicator = false
        
        //self.view.backgroundColor = AppTheme.Color.primaryBlue
        //self.scrollView.backgroundColor = .clear //AppTheme.Color.backgroundBlue
        
        priceSlider.minimumValue = 0
        priceSlider.maximumValue = 10
        priceSlider.tintColor = AppTheme.Color.primaryRed
        priceSlider.maximumTrackTintColor = UIColor.from(hex: "012D6C")
        
        pickerView = UIPickerView()
        pickerView.backgroundColor = AppTheme.Color.backgroundBlue
        
        
        
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        self.brandTextField.delegate = self
        self.brandTextField.tag = 1
        self.brandTextField.inputView = pickerView
        
        self.modelTextField.delegate = self
        self.modelTextField.tag = 2
        self.modelTextField.inputView = pickerView
        
        if self.searchHistory != nil {
           
            if searchHistory!.price == "" {
                //self.priceLabel.text = "Any"
            }else{
            var price = Float(searchHistory!.price) ?? 1.0
             price = price == 1.0 ? price : price/100000
            self.priceSlider.value = price
           
        }
        }
        
    }
    
    @IBAction func btnCheckAction(_ sender: UIButton) {
        bikeConditionAny = !bikeConditionAny
    }
    func updatePriceLabel(price: String) {
        print("price= ",price)
        self.priceLabel.text = price
        
    }
    
    func updateBrandLabel(brand: String) {
        self.brandTextField.text = brand
        self.modelTextField.text = "Any"
    }
    
    func updateModelLabel(model: String) {
        self.modelTextField.text = model
    }
    
    func updateStarRating(condition: Int){
        if condition == 100 {
            self.starRatingView.currentRating = 3
            self.bikeConditionAny = true
            return
        }
        self.bikeConditionAny = false
        self.starRatingView.currentRating = condition
    }
    
    func showLoadingIndicator() {
        LoadingIndicatorView.show()
    }
    
    func hideLoadingIndicator() {
        LoadingIndicatorView.hide()
    }
    
    func showError(error: AppError) {
        showAlert(title: "", message: error.localizedDescription)
    }
    
    func showMessage(message: String) {
        showAlert(title: "", message: message)
    }
    
    // Button Actions
    
    @IBAction func onSearchButtonTapped(_ sender: UIButton) {
        let filterSettings = presenter.getFilter()
        self.dismiss(animated: true){
            self.delegate.didChangeSearchFilter(brand: filterSettings.brand, model: filterSettings.model, price: filterSettings.price, condition: self.bikeConditionAny ? 100 : self.starRatingView.currentRating)
        }
    }
    
    
    @IBAction func onDoneButtonTap(_ sender: Any) {
        
    }
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.dismiss(animated: true){
            self.delegate.didClickedCancel(wasSearchOn: self.searchHistory != nil)
            self.searchHistory = nil
        }
    }
    
    
    @IBAction func onSliderValueChanged(_ sender: UISlider) {

        presenter.updatePriceFilter(currentValue: sender.value)
    }
    
}

extension BikeSearchFilterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return presenter.optionCountForFilter(tag: activeTextFieldTag)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return presenter.optionForFilter(tag: activeTextFieldTag, row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        presenter.setFilter(tag: activeTextFieldTag, selectedOptionIndex: row)
    }
}

extension BikeSearchFilterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextFieldTag = textField.tag
        pickerView.reloadAllComponents()        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextFieldTag = textField.tag
        
        return presenter.shouldShowFilterOptions(tag: activeTextFieldTag)
    }
}

