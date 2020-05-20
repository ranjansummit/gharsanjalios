//
//  BikePreviewViewController.swift
//  BhatBhate
//
//  Created by Nishan-82 on 7/13/17.
//  Copyright © 2017 Andmine. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
enum BikePreviewState {
    case buyPreview    // When buyer is looking for the listing
    case publish       // When seller is creating his new listing
    case draft         // When seller clicked on his saved draft
    case sellPreview   // When seller is looking his published listing
    case sellPreviewPublished // When seller is looking his published listing
    case wishlist // detail shown from wishlist
}

protocol BikeReloadDelegate:class {
    func reloadBikeList()
}

class BikePreviewViewController: RootViewController,BikePreviewViewPresentation, UIScrollViewDelegate {
    
    @IBOutlet weak var imgEdit: UIImageView!
    
    @IBOutlet weak var btnEditPrice: UIButton?
    @IBOutlet weak var lblYouWillUse: UILabel!{
        didSet{
           // print("In bike preview = ",Defaults[.isInReview])
            if Defaults[.promotionMode] {
                lblYouWillUse.text = "Important: Only bike price is editable after publishing."
            }else{
                lblYouWillUse.text = "You will use 1 credit to publish.\nImportant: Only bike price is editable after publishing."
            }
            if Defaults[.isInReview] {
                   lblYouWillUse.text = "1 credit will be used to inspect your bike physically.\nNote: Our team will meet you within 24 hours to inspect your bike. "
            }
        }
    }
    @IBOutlet weak var lblTermsAndCondition: UILabel!{
        didSet {
            let str = "I accept the terms and conditions."
            let tacWordRange = (str as NSString).range(of: "terms and conditions")
            let attString:NSMutableAttributedString = NSMutableAttributedString(string: str)
            attString.setAttributes([NSAttributedString.Key.foregroundColor:UIColor.blue], range: tacWordRange)
            lblTermsAndCondition.attributedText = attString
        }
    }
    // Outlets
    
    
    @IBOutlet weak var btnRemoveFromListing: UIButton?
    @IBOutlet weak var btnMarkAsSold: UIButton?
    
    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var mainContainerView: UIView!
    
    @IBOutlet weak var imgCheckBox: UIImageView!
    
    @IBOutlet var ratingView: StarRatingView!
    @IBOutlet var sellerImageView: UIImageView!
    
    @IBOutlet weak var sellerProfileLabel: UILabel!{
        didSet{
            sellerProfileLabel.addRoundedCorner(radius: 50)
        }
    }
    
    @IBOutlet weak var txtPrice: UITextField!{
        didSet{
            
        }
    }
    
    @IBOutlet var imageScrollView: UIScrollView!
    @IBOutlet var imagePageControl: UIPageControl!
    
    @IBOutlet var bikeTitleLabel: UILabel!
    @IBOutlet var bikeEngineLabel: UILabel!
    @IBOutlet var vehicleLotLabel: UILabel!
    @IBOutlet var odometerLabel: UILabel!
    @IBOutlet var mileageLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet var sellerNameLabel: UILabel!
    @IBOutlet var actionDescriptionLabel: UILabel!
    
    @IBOutlet var actionButton: UIButton!
    
    @IBOutlet weak var imageViewFavourite: UIImageView!
    @IBOutlet weak var btnChangeFavourite: UIButton!
    
    @IBOutlet weak var constraintBtnTop: NSLayoutConstraint!
    @IBOutlet weak var constraintlblButtom: NSLayoutConstraint!
    @IBOutlet weak var constraintBtnHeight: NSLayoutConstraint!
    // Properties
    var showPriceChangePopUp = true
    private var imageView:UIImageView!
    private var presenter:BikePreviewPresenter!
    public weak var viewDelegate : BikeReloadDelegate?
    public var previewState:BikePreviewState!
    public var bike: Bike?
    public var fromEdit = false
    fileprivate var wishListUpdated = false
    fileprivate var acceptTAC = false{
        didSet {
            if acceptTAC == true {
                imgCheckBox.image = #imageLiteral(resourceName: "ic_checked")
                
            }else {
                imgCheckBox.image = #imageLiteral(resourceName: "ic_unchecked")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let bike = bike else { fatalError("Bike model must be passed from parent") }
      //  print("seller image=",bike.sellerImage)
        presenter = BikePreviewPresenter(viewDelegate: self,state:previewState,bikeModel: bike)
        presenter.displayBikePreview()
    }
    
    func setupViews(forState state: BikePreviewState) {
        //   self.title = "Preview"
        ratingView.spacing = 0
        ratingView.isEditable = false
        sellerImageView.addRoundedCorner(radius: 50)
        //        sellerProfileLabel.addRoundedCorner(radius: 50)
        switch state {
            
        case BikePreviewState.draft:
            // setupButton(withTitle: "PUBLISH")
            actionDescriptionLabel.text = "Important: Only bike price is editable after publishing."
            actionDescriptionLabel.textAlignment = .left
            sellerNameLabel.text = ""
            sellerNameLabel.textAlignment = .left
            actionButton.addTarget(self, action: #selector(publishFromDraft), for: .touchUpInside)
            btnRemoveFromListing?.backgroundColor = .red
            btnRemoveFromListing?.setTitle("Remove from draft", for: .normal)
            btnRemoveFromListing?.addTarget(self, action: #selector(removeFromDraft), for: .touchUpInside)
            
            btnMarkAsSold?.backgroundColor = UIColor.from(hex: "#00A86B")
            btnMarkAsSold?.setTitle("Publish", for: .normal)
            btnMarkAsSold?.addTarget(self, action: #selector(publishFromDraft), for: .touchUpInside)
            actionButton.backgroundColor = .white
            //  let rightBarButton = UIBarButtonItem(title: "Remove", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onRightBarButtonTap(_:)))
            //  self.navigationItem.rightBarButtonItem = rightBarButton
            
        case BikePreviewState.sellPreview:
            setupButton(withTitle: "SAVE AS DRAFT")
            actionDescriptionLabel.text = "Your ad will be saved so that you can publish it anytime"
            sellerImageView.sd_setImage(with: URL(string: Defaults[.userPicURL] ?? ""), completed: nil)
            //            sellerNameLabel.text = "Seller Information"
            //            sellerNameLabel.textAlignment = .left
            // let rightBarButton = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onRightBarButtonTap(_:)))
            //  self.navigationItem.rightBarButtonItem = rightBarButton
            
        case BikePreviewState.publish:
            
            setupButton(withTitle: "SAVE AS DRAFT")
            actionDescriptionLabel.text = "Your ad will be saved so that you can publish it anytime"
            
            let rightBarButton = UIBarButtonItem(title: "Remove", style: UIBarButtonItem.Style.plain, target: self, action: #selector(onRightBarButtonTap(_:)))
            self.navigationItem.rightBarButtonItem = rightBarButton
            
        case BikePreviewState.buyPreview:
            setupForBuyPreview()
        case .sellPreviewPublished:
            actionButton.isHidden = false
            actionButton.backgroundColor = .white
            actionDescriptionLabel.isHidden = true
            txtPrice.isHidden = false
            priceLabel.isHidden = true
            txtPrice.delegate = self
            imgEdit.isHidden = false
           
            btnRemoveFromListing?.backgroundColor = .red
            btnRemoveFromListing?.setTitle("Remove from listing", for: .normal)
            btnRemoveFromListing?.addTarget(self, action: #selector(removeFromDraft), for: .touchUpInside)
            
            btnMarkAsSold?.backgroundColor = UIColor.from(hex: "#00A86B")
            btnMarkAsSold?.setTitle("Mark as sold", for: .normal)
            btnMarkAsSold?.addTarget(self, action: #selector(markASSold), for: .touchUpInside)
            if self.bike!.isSold {
                btnMarkAsSold?.setTitle("Already Sold", for: .normal)
                btnMarkAsSold?.isEnabled = false
                priceLabel.isHidden = false
                imgEdit.isHidden = true
                txtPrice.isHidden = true
            }else{
                 btnEditPrice?.addTarget(self, action: #selector(editPrice), for: .touchUpInside)
            }
            
        case .wishlist:
            btnRemoveFromListing?.isHidden = true
            btnMarkAsSold?.isHidden = true
            btnChangeFavourite.isHidden = false
            imageViewFavourite.isHidden = false
            setupButton(withTitle: self.bike!.isRequestSent ? "Contact already made.":"Request Seller Info")
            actionDescriptionLabel.text = "You will be provided with seller information once your request is accepted"
            actionButton.addTarget(self, action: #selector(onRequestSellerInfoButtonTap), for: .touchUpInside)
        }
        
        
    }
    
    @IBAction func actionTermsAndCondition(_ sender: UIButton) {
       // print("clicked")
        acceptTAC = !acceptTAC
    }
    
    
    @IBAction func actionShowTAC(_ sender: UIButton) {
        //        let termsAndCondVC = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: TermsAndConditionViewController.stringIdentifier) as! TermsAndConditionViewController
        //        present(termsAndCondVC, animated: true, completion: nil)
    }
    
    
    func BikeUploadSucceeded(isDraft:Bool) {
        let msg = isDraft ? "Vehicle saved as draft successfully." : "Vehicle published successfully"
        showAlert(title: "Success", message: msg){
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func updateBike(wished: Bool) {
        wishListUpdated = true
        // If preview is from wish list and wish list is removed
        if self.previewState == .wishlist {
            Defaults[.reloadBuyListing] = true
            showAlert(title: "", message: "Bike removed from wishlist"){
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        // If preview is other than from wishlist
        bike?.isInWishlist = wished
        self.imageViewFavourite.image = wished ? #imageLiteral(resourceName: "ic_favourite_full") : #imageLiteral(resourceName: "ic_favourite_empty")
    }
    
    func updateBadge(remainingCredit: Int) {
        
    }
    
    func displayMessage(message:String){
        showAlert(title: "", message: message)
    }
    
    @IBAction func addToWishList(_ sender: Any) {
        if bike?.isInWishlist ?? false {
            presenter.removeBikeFromWishlist(bikeID: bike?.id)
        }else{
            presenter.addBikeToWishlist(bikeID: bike?.id)
        }
    }
    
    @IBAction func actionSaveDraft(_ sender: UIButton) {
        if acceptTAC {
            presenter.performSaveDraftAction()
        }else{
            showAlert(title: "", message: "You are required to accept terms and conditions.")
        }
    }
    
    @IBAction func previewActionButtonClicked(_ sender: UIButton) {
        switch previewState {
        case .sellPreview?:
            if acceptTAC {         
                presenter.performActionOnRightButtonTap()
            }else{
                showAlert(title: "", message: "You are required to accept terms and conditions.")
            }
            
        //   presenter.performSaveDraftAction()
        default:
            break
        }
    }
    func updateBikeInfo(bike: Bike) {
        //dump(bike)
        bikeTitleLabel.text = bike.modelName
        bikeEngineLabel.text = "\(bike.engineCapacity ?? "0")cc"
        ratingView.currentRating = bike.conditionRating ?? 0
        vehicleLotLabel.text = bike.vehicleLot
        odometerLabel.text = "\(bike.odometerReading ?? "0") KM"
        mileageLabel.text = "\(bike.mileage ?? "0") KM/L"
        
        let price = Double(bike.price!) ?? 0
        txtPrice.text = "Rs. \(price.formatCurrency())"
        priceLabel.text = "Rs. \(price.formatCurrency())"
        if let sellerName = bike.sellerName {
            sellerNameLabel.text = sellerName
            sellerNameLabel.textAlignment = .center
        }else {
            sellerNameLabel.text = ""//"Seller Information"
            sellerNameLabel.textAlignment = .left
        }
        
        if let imageURL = bike.sellerImage , imageURL != "" {
            sellerImageView.isHidden = false
            sellerProfileLabel.isHidden = true
            sellerImageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        }else{
            let firstCharacter:Character?
            if previewState == BikePreviewState.sellPreview{
                let seller = Defaults[.userName]
                firstCharacter = seller?.uppercased().first
            }else{
                firstCharacter = sellerNameLabel.text?.uppercased().first
            }
            guard let char = firstCharacter else{
                return
            }
            sellerImageView.isHidden = true
            sellerProfileLabel.isHidden = false
            sellerProfileLabel.text = "\(String(describing: char))"
            sellerProfileLabel.backgroundColor = AppTheme.Color.primaryBlue
        }
        
        imageViewFavourite.image = bike.isInWishlist ? #imageLiteral(resourceName: "ic_favourite_full") : #imageLiteral(resourceName: "ic_favourite_empty")
        if let imageUrls = bike.imageURL {
            setupBikeImages(images: imageUrls)
        }
        if let image = bike.image {
            setupBikeImages(images: image)
        }
    }
    
    func displaySuccessIfNotifiedToSeller(message: String) {
        
        actionButton.setTitle("Contact already made.", for: .normal)
        showAlert(title: "", message: message)
    }
    
    func displayError(error: AppError) {
        showAlert(title: "", message: error.localizedDescription)
    }
    
    
    
    // MARK:- Button Actions
    
    @objc func onRightBarButtonTap(_ sender:UIBarButtonItem) {
        
        presenter.performActionOnRightButtonTap()
    }
    
    @objc func markASSold(){
        guard let id = self.bike?.id else {
            return
        }
        
        self.showYesNoAlert(title: "", message: "Are you sure you want to mark this bike as sold?"){
            yes in
            if yes {
                self.showLoadingIndicator()
                ApiManager.sendRequest(toApi: .MarkAsSold(VehicleID: id), onSuccess: {
                    status , response in
                    self.hideLoadingIndicator()
                    print(status)
                    print(response)
                    if status == 200 {
                        let message = response["message"].string ?? "Your bike is now marked as sold."
                        Defaults[.reloadSellLsting] = true
                        self.showAlert(title: "", message: message){
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        self.showAlert(title: "", message: "Could not mark as sold right now"){
                        }
                    }
                    
                }, onError: {error  in
                    self.hideLoadingIndicator()
                    print(error.localizedDescription)
                })
            }
        }
    }
    
    @objc func removeFromDraft(){
        guard let id = self.bike?.id else {
            return
        }
        let message = previewState == BikePreviewState.draft ? "Are you sure you want to remove this bike from draft?" : "Are you sure you want to remove this bike from listing?"
        self.showYesNoAlert(title: "", message: message){
            yes in
            if yes {
                self.showLoadingIndicator()
                ApiManager.sendRequest(toApi: .DeleteVehicle(vehicleID: id), onSuccess: {status , response in
                    self.hideLoadingIndicator()
                    /*
                     200
                     {
                     "message" : "Successfully deleted.",
                     "data" : null,
                     "error" : false
                     }
                     */
                    
                    if status == 200 {
                        let message = response["message"].string ?? "Your bike is removed  successfully"
                        Defaults[.reloadSellLsting] = true
                        self.showAlert(title: "", message: message){
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else{
                        self.showAlert(title: "", message: "Could not delete right now"){
                        }
                    }
                    
                }, onError: {error in
                    self.hideLoadingIndicator()
                //    print(error.localizedDescription)
                })
            }else{
              //  print("do nothing")
            }
        }
    }
    
    @objc func publishFromDraft(){
        guard let id = self.bike?.id else {
            return
        }
        self.showLoadingIndicator()
        ApiManager.sendRequest(toApi: .publishBike(bikeID: id), onSuccess: {
            statusCode , response in
            //print(response)
            self.hideLoadingIndicator()
            if let error = response["error"].bool , error {
                
                let message = response["message"].string
                self.showAlert(title: "", message: message!)
                return
            }else{
                if let remainingCredit = response["data"]["remaining_credit"].int{
                    Defaults[.userPublishedBikeCount] = response["data"]["listing_vehicle"].int!
                    Defaults[.userCreditCount] = remainingCredit
                    self.tabBarController?.tabBar.items?[2].badgeValue = "\(remainingCredit)"
                  //  let creditCount = Defaults[.userCreditCount]
                    //let stringCredit = creditCount > 1 ? "credits" : "credit"
                }
                let message =  response["message"].string!
                Defaults[.reloadSellLsting] = true
                self.showAlert(title: "Success", message: message){
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }, onError: {
            error in
            self.hideLoadingIndicator()
          //  print(error)
        })
    }
    @objc func showLoginPage(){
        showLoginScreen()
    }
    @objc func onRequestSellerInfoButtonTap() {
        if checkEmailAndMobileISEmpty(){
            return
        }
        if self.bike!.isRequestSent {
            let notificationVC = UIStoryboard.buyPathway.instantiateViewController(withIdentifier: BuyNotificationsViewController.stringIdentifier) as! BuyNotificationsViewController
            self.navigationController?.pushViewController(notificationVC, animated: true)
            return
        }
        self.wishListUpdated = self.previewState == BikePreviewState.wishlist
        presenter.notifySellerForInterestInPurchase()
    }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    
    //MARK:- Helper functions
    
    private func checkEmailAndMobileISEmpty()->Bool{
        if Defaults[.userEmail] == "" || Defaults[.userMobile] == "" {
            let navVC = UIStoryboard.main.instantiateViewController(withIdentifier: CollectInfoNavViewController.stringIdentifier) as! CollectInfoNavViewController
            let collectVc = navVC.viewControllers.first as? UserInformationFormController
            collectVc?.userEmail = Defaults[.userEmail]
            collectVc?.userMobile = Defaults[.userMobile]
            self.present(navVC, animated: true, completion: nil)
            return true
        }
        return false
    }
    private func setupButton(withTitle title:String) {
        
        actionButton.isHidden = false
        actionDescriptionLabel.isHidden = false
        
        actionButton.setTitle(title, for: .normal)
        actionButton.setTitle(title, for: .selected)
    }
    
   
    
    
    private func setupBikeImages(images:[Any]) {
        
        imageScrollView.layoutIfNeeded()
        
        let imageViewWidth = imageScrollView.frame.width
        let imageViewHeight = imageScrollView.frame.height
        
        var xPosition:CGFloat = 0
        
        for (index,image) in images.enumerated() {
            
            xPosition = CGFloat(index) * imageViewWidth
            
            imageView = UIImageView(frame: CGRect(x: xPosition, y: 0, width: imageViewWidth, height: imageViewHeight))
        
            imageView.contentMode = .scaleAspectFit
            //imageView.image = image
            switch previewState {
            case .sellPreview?:
                imageView.image = image as? UIImage
            default:
                imageView.sd_setImage(with: URL(string: image as! String), completed: nil)
            }
            
            self.imageScrollView.addSubview(imageView)
        }
        
        imageScrollView.contentSize = CGSize(width: xPosition + imageViewWidth, height: imageViewHeight)
        imageScrollView.delegate = self
        imageScrollView.isPagingEnabled = true
        
        
        // Setup Page Control
        imagePageControl.numberOfPages = images.count
        imagePageControl.tintColor = AppTheme.Color.backgroundBlue
        imagePageControl.pageIndicatorTintColor = AppTheme.Color.backgroundBlue
        imagePageControl.currentPageIndicatorTintColor = AppTheme.Color.primaryBlue
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.x
        let frameWidth = scrollView.frame.width
        
        let currentPage = Int(currentOffset / frameWidth)
        
        imagePageControl.currentPage = currentPage
    }
    
    //    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    //        return imageView
    //    }
    func setupForBuyPreview(){
        if Defaults[.accessToken] == nil {
            btnChangeFavourite.isHidden = true
            imageViewFavourite.isHidden = true
            actionButton.setTitle("Login to request the seller information.", for: .normal)
            actionButton.addTarget(self, action: #selector(showLoginPage), for: .touchUpInside)
            actionDescriptionLabel.text = ""
        }
        else if (bike?.isSold)! {
            btnChangeFavourite.isHidden = true
            imageViewFavourite.isHidden = true
            actionButton.setTitle("Vehicle already sold.", for: .normal)
            actionDescriptionLabel.text = ""
        }else{
            btnChangeFavourite.isHidden = false
            imageViewFavourite.isHidden = false
            setupButton(withTitle: self.bike!.isRequestSent ? "Contact already made.":"Request Seller Info")
            actionDescriptionLabel.text = "You will be provided with seller information once your request is accepted."
            actionButton.addTarget(self, action: #selector(onRequestSellerInfoButtonTap), for: .touchUpInside)
        }
        btnMarkAsSold?.isHidden = true
        btnRemoveFromListing?.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        if previewState == BikePreviewState.buyPreview {
            return
        }
        guard let _ = Defaults[.accessToken] else {
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        txtPrice.isEnabled = false
        switch previewState! {
        case .buyPreview:
           setupForBuyPreview()
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if wishListUpdated {
            viewDelegate?.reloadBikeList()
        }
    }
    
    
    @objc func editPrice() {
        txtPrice.isEnabled = true
        txtPrice.delegate = self
        txtPrice.becomeFirstResponder()
        showPriceChangePopUp = true
    }
    
}


extension BikePreviewViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = bike?.price
        //print("did begin editing")
    }
    
   
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let bikePrice = Int(bike?.price ?? "0") ?? 0
        guard let price = Int(textField.text!) , price != 0 else {
            self.showAlert(title: "", message: "Invalid price")
            textField.text = bike?.price
            return true
        }
        
        if price == bikePrice {
            txtPrice.delegate = nil
            let price = Double(self.bike!.price!) ?? 0
            self.txtPrice.text = "Rs. \(price.formatCurrency())"
            self.txtPrice.resignFirstResponder()
            return true
        }
        
        if !showPriceChangePopUp {
            return true
        }
        self.showPriceChangePopUp = false
        self.view.endEditing(true)
         textField.isEnabled = false
        txtPrice.delegate = nil
        self.showYesNoAlert(title: "", message: "Are you sure you really want to change the price of your bike?"){
            yes in
            if yes {
                self.showLoadingIndicator()
                ApiManager.sendRequest(toApi: .EditVehiclePrice(vehicleID: self.bike!.id!, price: price), onSuccess: {status , response in
                    self.hideLoadingIndicator()
                    if status == 200 {
                        let message = response["message"].string ?? "Successfully change the price of your bike"
                        textField.text = "Rs. \(Double(price).formatCurrency())"
                        Defaults[.reloadSellLsting] = true
                        self.showAlert(title: "", message: message){
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }, onError: {error in
                    self.hideLoadingIndicator()
                    
                })
            }else{
           // print("clicked no.don't update i am ok")
                let price = Double(self.bike!.price!) ?? 0
                self.txtPrice.text = "Rs. \(price.formatCurrency())"
              self.txtPrice.resignFirstResponder()
               
            }
            
        }
        
        
        return true
    }
}
